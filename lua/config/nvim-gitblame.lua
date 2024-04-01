require('gitblame').setup {
    enabled = false,
    message_template = ' -> <summary> • <date> • <author>',
    message_when_not_committed = ' -> Not committed',
    date_format = '%b %d %Y %H:%m',
    delay = 1000, -- 1 second delay
}
