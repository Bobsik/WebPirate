.pragma library

var defaultuseragents = [ {"type": "Mobile",     "value": "" },
                          {"type": "Desktop Linux",    "value": "Mozilla/5.0 (X11; Linux) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809 Safari/537.36" },
                          {"type": "Waterfox Windows",    "value": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:55.0) Gecko/20100101 Firefox/55.2.2 Waterfox/55.2.2" },
                          {"type": "Android",    "value": "Mozilla/5.0 (Linux; Android 4.4; Nexus 4 Build/KRT16H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/76.0.0.0 Mobile Safari/537.36" },
                          {"type": "iPhone",     "value": "Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B179 Safari/7534.48.3" },
                          {"type": "Google Bot", "value": "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" } ];

function load(tx)
{
    tx.executeSql("DROP TABLE IF EXISTS UserAgents");
}

function get(idx)
{
    return defaultuseragents[idx];
}

function buildUA(version, wkversion) {
    defaultuseragents[0].value = "Mozilla/5.0 (U; Linux; Maemo; Jolla; Sailfish; like Android 4.3) " +
                                 "AppleWebKit/" + wkversion + " (KHTML, like Gecko) WebPirate/" + version + " like Mobile Safari/" + wkversion + " (compatible)";
}
