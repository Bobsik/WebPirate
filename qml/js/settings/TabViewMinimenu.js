.pragma library

var tabside = [ {"type": "Left",     "value": "left" },
                {"type": "Right",    "value": "right" },
]
function loadside(tx)
{
    tx.executeSql("DROP TABLE IF EXISTS TabSide");
}

function getside(idx)
{
    return tabside[idx];
}
