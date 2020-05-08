.pragma library

var browsemenus = [ {"type": "Pull Down Menu",     "value": "pulldown" },
                    {"type": "Push Up Menu",    "value": "pushup" },
                    {"type": "MiniMenu (Phone UI only)",    "value": "minimenu" },
]
function load(tx)
{
    tx.executeSql("DROP TABLE IF EXISTS BrowseMenu");
}

function get(idx)
{
    return browsemenus[idx];
}
