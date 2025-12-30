return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true,        -- enable treesitter
            ts_config = {
                lua = { "string" }, -- it will not add a pair on that treesitter node
                javascript = { "template_string" },
                java = false,       -- don't check treesitter on java
            },
        })

        -- Safely set up cmp integration
        local cmp_status_ok, cmp = pcall(require, "cmp")
        if cmp_status_ok then
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    end,
}
