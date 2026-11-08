-- Java: nvim-jdtls drives eclipse.jdt.ls (installed by Mason) with Lombok,
-- one server per repo, per-project data dirs, JDKs discovered from mise,
-- Spring Boot tooling and SonarLint. Debugging is left to IntelliJ.
--
-- jdtls must NOT be in vim.lsp.enable() (lsp.lua): nvim-jdtls starts it itself.

local function mason_root()
  return vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
end

--- JDKs installed through mise.
--- Returns jdtls "runtimes" (so projects on Java 8/11/17/... resolve correctly)
--- and a JDK >= 21 to run jdtls itself, regardless of the project's JDK.
local function mise_jdks()
  local data = vim.env.MISE_DATA_DIR or ((vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/mise")
  local by_major = {}
  for _, dir in ipairs(vim.fn.glob(data .. "/installs/java/*", false, true)) do
    local real = vim.uv.fs_realpath(dir)
    local major = tonumber(vim.fs.basename(dir):match("(%d+)"))
    if real and major then
      local home
      if vim.uv.fs_stat(real .. "/bin/java") then
        home = real
      elseif vim.uv.fs_stat(real .. "/Contents/Home/bin/java") then
        home = real .. "/Contents/Home"
      end
      if home then
        by_major[major] = home -- later (newer) patch versions win
      end
    end
  end

  local current = vim.env.JAVA_HOME and vim.uv.fs_realpath(vim.env.JAVA_HOME)
  local majors = vim.tbl_keys(by_major)
  table.sort(majors)

  local runtimes, server_home = {}, nil
  for _, major in ipairs(majors) do
    table.insert(runtimes, {
      name = major == 8 and "JavaSE-1.8" or ("JavaSE-" .. major),
      path = by_major[major],
      default = current == by_major[major] or nil,
    })
    if major >= 25 then
      server_home = server_home or by_major[major] -- lowest JDK >= 25 is required for latest jdtls
    end
  end
  return runtimes, server_home
end

local function nearest_method(bufnr)
  local node = vim.treesitter.get_node({ bufnr = bufnr })
  while node and node:type() ~= "method_declaration" do
    node = node:parent()
  end
  local name = node and node:field("name")[1]
  return name and vim.treesitter.get_node_text(name, bufnr) or nil
end

--- Run the test class (or nearest test method) in a terminal split via
--- Maven/Gradle, using the repo's wrapper when present.
local function run_tests(bufnr, scope)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local module = vim.fs.root(file, { "pom.xml", "build.gradle", "build.gradle.kts" })
  if not module then
    return vim.notify("No Maven/Gradle module found", vim.log.levels.WARN)
  end
  local top = vim.fs.root(file, { { "mvnw", "gradlew" } }) or module
  local class = vim.fn.fnamemodify(file, ":t:r")
  local method = scope == "method" and nearest_method(bufnr) or nil

  local cmd
  if vim.uv.fs_stat(module .. "/pom.xml") then
    cmd = {
      vim.uv.fs_stat(top .. "/mvnw") and (top .. "/mvnw") or "mvn",
      "-f",
      module .. "/pom.xml",
      "-Dsurefire.failIfNoSpecifiedTests=false",
      "-Dtest=" .. class .. (method and ("#" .. method) or ""),
      "test",
    }
  else
    cmd = {
      vim.uv.fs_stat(top .. "/gradlew") and (top .. "/gradlew") or "gradle",
      "test",
      "--tests",
      "*" .. class .. (method and ("." .. method) or ""),
    }
  end

  if _G.Snacks and Snacks.terminal then
    Snacks.terminal(cmd, { cwd = module, interactive = false, win = { position = "bottom", height = 0.3 } })
  else
    vim.cmd("botright 15new")
    vim.fn.jobstart(cmd, { term = true, cwd = module })
  end
end

local function on_attach(_, bufnr)
  local jdtls = require("jdtls")
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Java: " .. desc })
  end

  pcall(function()
    require("which-key").add({ { "<leader>j", group = "java", buffer = bufnr } })
  end)

  map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
  map("n", "<leader>jv", jdtls.extract_variable, "Extract variable")
  map("n", "<leader>jV", jdtls.extract_variable_all, "Extract variable (all occurrences)")
  map("n", "<leader>jc", jdtls.extract_constant, "Extract constant")
  map("x", "<leader>jv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract variable")
  map("x", "<leader>jc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract constant")
  map("x", "<leader>jm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract method")

  map("n", "<leader>jt", function()
    run_tests(bufnr, "class")
  end, "Test class")
  map("n", "<leader>jT", function()
    run_tests(bufnr, "method")
  end, "Test nearest method")

  map("n", "<leader>jb", "<Cmd>JdtCompile full<CR>", "Full build (errors to quickfix)")
  map("n", "<leader>ju", "<Cmd>JdtUpdateConfig<CR>", "Reload pom/gradle config")
  map("n", "<leader>jr", "<Cmd>JdtRestart<CR>", "Restart jdtls")
  map("n", "<leader>jW", "<Cmd>JdtWipeDataAndRestart<CR>", "Wipe workspace data + restart")
end

local function attach(bufnr)
  if vim.bo[bufnr].buftype ~= "" then
    return
  end
  local jdtls = require("jdtls")

  -- One server per repo: wrapper/settings/.git beat nested module poms, so
  -- multi-module projects don't spawn a jdtls per module.
  local root = vim.fs.root(bufnr, {
    { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" },
    { "pom.xml", "build.gradle", "build.gradle.kts" },
  })
  root = root or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)) -- single-file mode
  if not root or root == "" then
    return
  end

  local data = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 8)

  local bin = vim.fn.exepath("jdtls")
  if bin == "" then
    bin = mason_root() .. "/bin/jdtls"
  end
  local cmd = { bin, "-configuration", data .. "/config", "-data", data .. "/workspace" }
  local lombok = mason_root() .. "/share/jdtls/lombok.jar"
  if vim.uv.fs_stat(lombok) then
    table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
  end

  local runtimes, server_jdk = mise_jdks()

  local capabilities = require("blink.cmp").get_lsp_capabilities({
    textDocument = { completion = { completionItem = { snippetSupport = false } } },
  })

  local ext = vim.deepcopy(jdtls.extendedClientCapabilities)
  ext.resolveAdditionalTextEditsSupport = true

  local bundles = {}
  local ok, spring = pcall(require, "spring_boot")
  if ok then
    vim.list_extend(bundles, spring.java_extensions())
  end

  jdtls.start_or_attach({
    name = "jdtls",
    cmd = cmd,
    -- jdtls itself needs JDK >= 21 even when the project is pinned to an older JDK
    cmd_env = server_jdk and { JAVA_HOME = server_jdk } or nil,
    root_dir = root,
    capabilities = capabilities,
    on_attach = on_attach,
    init_options = { bundles = bundles, extendedCapabilities = ext },
    settings = {
      java = {
        configuration = { updateBuildConfiguration = "automatic", runtimes = runtimes },
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        references = { includeDecompiledSources = true },
        implementationsCodeLens = { enabled = false },
        referencesCodeLens = { enabled = false },
        signatureHelp = { enabled = true, description = { enabled = true } },
        inlayHints = { parameterNames = { enabled = "literals" } },
        completion = {
          importOrder = { "java", "javax", "jakarta", "org", "com" },
          filteredTypes = {
            "java.awt.*",
            "com.sun.*",
            "sun.*",
            "jdk.*",
            "org.graalvm.*",
            "io.micrometer.shaded.*",
          },
          favoriteStaticMembers = {
            "org.junit.Assert.*",
            "org.junit.Assume.*",
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
            "org.assertj.core.api.Assertions.*",
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
            "org.mockito.Answers.*",
            "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
            "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
          },
        },
        sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
        codeGeneration = {
          useBlocks = true,
          hashCodeEquals = { useJava7Objects = true },
        },
      },
    },
  })
end

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- Fix for workspace/executeClientCommand missing response error in Neovim
      -- Fix for workspace/executeClientCommand in Neovim
      vim.lsp.handlers["workspace/executeClientCommand"] = function(err, result, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
          -- Execute the command or delegate it safely
          local command = result.command
          local arguments = result.arguments

          -- If jdtls provides a custom command handler, let it run,
          -- otherwise respond successfully to the server request.
          if client.commands and client.commands[command] then
            client.commands[command](result, ctx)
          end

          -- Send response back to server to satisfy RPC protocol
          client.request("workspace/executeClientCommand", result, function(_, _) end, ctx.bufnr)
        end
        return {}, nil
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("jovani_java", { clear = true }),
        pattern = "java",
        callback = function(args)
          attach(args.buf)
        end,
      })
      -- The FileType event that loaded this plugin already fired
      if vim.bo.filetype == "java" then
        attach(vim.api.nvim_get_current_buf())
      end
    end,
  },

  -- Spring Boot LS: application.yml/.properties completion, bean/endpoint
  -- navigation. Needs `vscode-spring-boot-tools` from Mason. Remove this block
  -- if you don't do Spring (attach() above skips it automatically).
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = { "mfussenegger/nvim-jdtls", "ibhagwan/fzf-lua" },
    opts = {},
  },

  -- SonarLint: IntelliJ-style inspections (code smells, bugs, security).
  -- Needs `sonarlint-language-server` from Mason; reads the classpath via jdtls.
  {
    url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
    name = "sonarlint.nvim",
    ft = "java",
    dependencies = { "mfussenegger/nvim-jdtls" },
    config = function()
      require("sonarlint").setup({
        server = {
          cmd = {
            mason_root() .. "/bin/sonarlint-language-server",
            "-stdio",
            "-analyzers",
            mason_root() .. "/share/sonarlint-analyzers/sonarjava.jar",
          },
        },
        filetypes = { "java" },
      })
    end,
  },
}
