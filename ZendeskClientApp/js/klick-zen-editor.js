"use strict";
{
    var client = ZAFClient.init();
    var API_URL = "https%3A%2F%2Flocal.klick-zen.com";
    var OAUTH_URL = ""; // this should be the CUSTOMER's subdomain // d3v-git-zen
    var OAUTH_NAM = "klick-zen_zendesk_app";
    var user;

    // fetch an auth code, set it here
    axios.defaults.headers.common['Authorization'] = initVars().JwtToken;
    axios.defaults.headers.common['Identifier'] = initVars().custObj.AccessGUID;

    var vm = new Vue({
        el: '#app',
        data: {
            appName: "Klick-Zen",

            V_DISABLED: 0,
            V_LITE: 1,
            V_TRIALFULL: 2,
            V_FULL: 3,

            cust: JSON.parse(JSON.stringify(initVars().custObj)), // must be cloned, or cust will change when custObj changes
            thisExecutionMode: initVars().executionMode,
            thisFreeVersionLimit: initVars().FreeVersionLimit,
            hasUsedTrialVersion: initVars().hasUsedTrial,
            auth: initVars().PreCheckAuth,
            agreeTOS: false,
            agreeFreeTrial: true,
            showPostApprove: false,
            isFullVersion: null,
            userIsAdmin: false,
            ticketLocked: false,
            tickData: {},
            buttons: [],
            custDomain: null,
            ticketCreatedAt: null
        },
        methods: {
            insertButton: function (button) {
                let insertTxt = `<a href="${vm.custDomain}ext/href/${button.AccessGuid}/${vm.tickData.ticket.id}/${vm.tickData.ticket.requester.id}/${vm.ticketCreatedAt}"><img src="${vm.custDomain}ext/src/${button.AccessGuid}/${vm.tickData.ticket.id}"/></a>`;
                client.invoke('ticket.editor.insert', insertTxt);
                client.invoke('app.close');
            }
        },
        computed: {
            enabledButtons: function () {
                return this.buttons.filter(u => u.Enabled);
            }
        },
        mounted: function () {
            this.cust_RESET = JSON.parse(JSON.stringify(this.cust));
            
        }
    }).$mount('#app');


    

    // check to see which version this is
    client.metadata().then(function (meta) {
        let thisAppId = meta.appId.toString();
        if (thisAppId === initVars().useageA || thisAppId === initVars().useageB) {
            vm.isFullVersion = true;
            vm.thisExecutionMode = vm.V_FULL;
        }
        else {
            vm.isFullVersion = false;
        }

        refreshButtons();

    });

    client.get('currentUser').then(function (data) {
        user = data['currentUser'];
        vm.userIsAdmin = user.role === "admin" || user.role === "owner";
    });

    client.get('ticket').then(function (tickDataResult) {
        vm.tickData = tickDataResult;
        vm.custDomain = "https://" + (vm.cust.CustomCNameDomain === "" ? window.location.hostname : vm.cust.CustomCNameDomain) + "/";
        vm.ticketCreatedAt = new Date(vm.tickData.ticket.createdAt).toISOString(); // need to convert to z time
        vm.ticketLocked = vm.tickData.ticket.status === "closed";
    });

    function refreshButtons() {
        return new Promise((resolve, reject) => {
            axios
                .get('/functions/KlickZenListButtons.ashx')
                .then(function (d) {
                    let calcWidth = "250px";
                    if (d.data.length) {
                        vm.buttons = d.data;
                        calcWidth = (d.data.length * 90).toString() + "px";
                    }
                    else {
                        vm.buttons = [];
                    }
                    client.invoke('resize', { width: calcWidth, height: '35px' });
                    resolve(d);
                })
                .catch(function (e) {
                    reject(e);
                });
        });
    }


    function logError(errMsg) {
        console.log(errMsg);
        axios
            .post('/functions/KlickZenLog.ashx', JSON.stringify({ "Text": errMsg }))
            .then(function (d) {
                //console.log(d);
            })
            .catch(function (e) {
                //console.log(e);
            });
    }
}