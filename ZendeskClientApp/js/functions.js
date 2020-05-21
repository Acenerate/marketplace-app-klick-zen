var msFactor = 60000; // allows use of minutes instead of milliseconds
var dateOffset = (new Date().getTimezoneOffset() / 60) * -1;
var dateFormatOptions = { year: 'numeric', month: 'numeric', day: 'numeric' };
var localCache = {
    remove: function (url) {
        localStor.removeItem(url);
    },
    exist: function (url) {
        var item = localStor.getItem(url);
        return (item && ((new Date().getTime() - JSON.parse(item)._) < localCache.timeout));
    },
    get: function (url) {
        //console.debug('Getting in cache for url ' + url);
        var item = JSON.parse(localStor.getItem(url));
        return item.data;
    },
    set: function (url, cachedData) {
        localStor.removeItem(url);
        localStor.setItem(url, JSON.stringify({
            _: new Date().getTime(),
            data: cachedData
        }));
    },
    clear: function () {
        localStor.clear();
    },
    timeout: msFactor * 15 // minutes
};


// localStorage wrapper
var lsSupported = false;
try {
    const key = "localStoreTest";
    window.localStorage.setItem(key, key);
    window.localStorage.removeItem(key);
    lsSupported = true;
} catch (e) {
    lsSupported = false;
}
// option here to add in-memory storage as an alternative perhaps
var localStor = {
    removeItem: function (i) {
        if (lsSupported) {
            window.localStorage.removeItem(i);
        }
    },
    getItem: function (i) {
        if (lsSupported) {
            return window.localStorage.getItem(i);
        }
        else {
            return "";
        }
    },
    setItem: function (i, v) {
        if (lsSupported) {
            window.localStorage.setItem(i, v);
        }
    },
    clear: function () {
        if (lsSupported) {
            window.localStorage.clear();
        }
    }
};
oXXil = function (s) {
    return Object.freeze(JSON.parse(atob(s)));
};
function copy(t) {
    var
        c = t.dataset.copytarget,
        inp = c ? document.querySelector(c) : null;
    if (inp && inp.select) {
        inp.select();
        try {
            document.execCommand('copy');
            inp.blur();
            t.classList.add('copied');
            setTimeout(function () { t.classList.remove('copied'); }, 1500);
        }
        catch (err) {
            alert('please press Ctrl/Cmd+C to copy');
        }

    }

}
replaceAll = function (string, find, replace) {
    return string.replace(RegExp(find, "g"), replace);
};

getCookie = function (name) {
    var cookie = null;
    name += "=";
    $.each(document.cookie.split(';'), function (index, value) {
        if (value.indexOf(name) !== -1) {
            cookie = value.substring(value.indexOf("=") + 1);
        }
    });
    return cookie;
};

setCookie = function (name, value, expirationDays) {
    var cookie = "";
    var expires;
    name += "=";
    if (expirationDays) {
        var date = new Date();
        date.setTime(date.getTime() + (expirationDays * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toUTCString();
    }
    else {
        // Never expires
        expires = "; expires=Fri, 31 Dec 9999 23:59:59 GMT";
    };
    cookie += name + value + expires;
    document.cookie = cookie;
};

locDate = function (time) {
    // Date and Time locally formatted
    var d = new Date(time);
    var n = new Date(d.getTime() + dateOffset);
    var hours = n.getHours();
    var minutes = n.getMinutes();
    var ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours ? hours : 12;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    var formattedTime = n.toLocaleDateString("en-us", dateFormatOptions) + ' ' + hours + ':' + minutes + ' ' + ampm;
    return formattedTime;
};
locDateOnly = function (date) {
    // Date only locally formatted
    var d = new Date(date);
    var n = new Date(d.getTime() + dateOffset);
    var formattedTime = n.toLocaleDateString("en-us", dateFormatOptions);
    return formattedTime;
};


var axiosData = [];
axiosCached = function (url, obj) {
    return new Promise((resolve, reject) => {
        // see if it exists first
        var cachedObject = null;
        obj = obj || { repo: "", owner: "", field: "", wiType: "" };
        obj.repo = obj.repo || "";
        obj.owner = obj.owner || "";
        obj.field = obj.field || "";
        obj.wiType = obj.wiType || "";
        // provide a key to store
        var objString = obj.repo + "|" + obj.owner + "|" + obj.field + obj.wiType;
        //var objString = JSON.stringify(obj);
        //console.log(objString);
        var oFil = axiosData.filter(o => o.url === url && o.obj === objString)[0];
        if (oFil) {
            cachedObject = oFil.content;
            resolve(cachedObject);
        }
        else {
            // make axios call, store the object in memory for future calls
            axios
                .post(url, obj)
                .then(function (d) {
                    if (d.data) {
                        cachedObject = d.data;
                    }
                    else {
                        cachedObject = [];
                    }
                    axiosData.push({ url: url, obj: objString, content: cachedObject });
                    resolve(cachedObject);
                })
                .catch(function (e) {
                    reject(e.message);
                });
        }

    });
};

String.prototype.isValidURL = function () {
    return /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test(this);
};

arrayRemove = function (arr, value) {
    return arr.filter(function (ele) {
        return ele !== value;
    });
}