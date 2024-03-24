local neogit = require('neogit')

-- open using defaults
neogit.open()

-- open commit popup
neogit.open({ "commit" })

-- open with split kind
neogit.open({ kind = "split" })

-- open home directory
neogit.open({ cwd = "%:p:h" })
