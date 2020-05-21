"use strict";
{
    var client = ZAFClient.init();
    var API_URL = "https%3A%2F%2F" + window.location.hostname; "https%3A%2F%2Flocal.klick-zen.com";
    var OAUTH_URL = ""; // this should be the CUSTOMER's subdomain // d3v-git-zen
    var OAUTH_NAM = "zdg-klick-zen";
    var user;
    const UnAuthMessage = "Request failed with status code 401";
    const PreconditionError = "Request failed with status code 428"; // when proper DNS entry does not exist
    var ActionTypes = {
        UpdateField: 1,
        SetStatus: 2,
        AddPrivateComment: 3,
        AddPublicComment: 4,
        AddTag: 5
    };

    const isLocalDev = window.location.host.indexOf("local.") !== -1;

    if (isLocalDev) {
        console.clear();
    }

    // fetch an auth code, set it here
    axios.defaults.headers.common['Authorization'] = initVars().JwtToken;
    axios.defaults.headers.common['Identifier'] = initVars().custObj.AccessGUID;

    // init multiselect
    Vue.component('multiselect', window.VueMultiselect.default);


    var vm = new Vue({
        el: '#app',
        data: {
            appName: "Klick-Zen",

            V_DISABLED: 0,
            V_LITE: 1,
            V_TRIALFULL: 2,
            V_FULL: 3,

            defaultScreen: "listButtons",

            FullVersionURL: "https://www.zendesk.com/apps/support/klick-zen/",

            globalTrackingEnabled: false,

            cust: JSON.parse(JSON.stringify(initVars().custObj)), // must be cloned, or cust will change when custObj changes
            thisExecutionMode: initVars().executionMode,
            thisFreeVersionLimit: initVars().FreeVersionLimit,
            hasUsedTrialVersion: initVars().hasUsedTrial,
            auth: initVars().PreCheckAuth,
            //ActionTypes: ActionTypes,
            agreeTOS: false,
            agreeFreeTrial: true,
            showPostApprove: false,
            isFullVersion: null,
            userIsAdmin: false,
            ticketLocked: false,
            showSection: 'splash',
            dataUnchanged: true,
            editMode: false,
            editModeDataChanged: false,
            viewSaving: false,
            viewGoodSave: false,
            viewBadSave: false,
            badSaveMessage: 'There was an issue with your request',
            validCreateButtonForm: false,
            validSettings: false,
            buttons: [],
            newButton: {},
            availableTicketFields: [],

            defaultButtonTemplate: {
                Name: "Blank Button",
                AccessGuid: "", // this is populated when there is an EDIT
                Active: true,
                Enabled: true,
                ReturnURL: "",
                BorderColor: "#666666",
                BackgroundColor: "#cccccc",
                Text: "Button Text",
                TextColor: "#000099",
                TextFont: "Arial",
                TextBold: false,
                TextItalic: false,
                Radius: 10,
                Actions: []
            },
            genericButtonTemplates: [
                {
                    Name: "Generic Button",
                    AccessGuid: "", // this is populated when there is an EDIT
                    Active: true,
                    Enabled: true,
                    ReturnURL: "",
                    BorderColor: "#666666",
                    BackgroundColor: "#cccccc",
                    Text: "Button Text",
                    TextColor: "#000099",
                    TextFont: "Arial",
                    TextBold: false,
                    TextItalic: false,
                    Radius: 10,
                    Actions: []
                },
                {
                    Name: "Solve Ticket",
                    AccessGuid: "",
                    Active: true,
                    Enabled: true,
                    Description: "Solves the ticket",
                    ReturnURL: "",
                    BorderColor: "#666666",
                    BackgroundColor: "#006c00",
                    Text: "Solve Ticket",
                    TextColor: "#ffffff",
                    TextFont: "Arial",
                    TextBold: false,
                    TextItalic: false,
                    Radius: 10,
                    Actions: [
                        {
                            "ActionType": ActionTypes.SetStatus,
                            "ActionTarget": null,
                            "ActionValue": "solved",
                            "Active": true
                        },
                        {
                            "ActionType": ActionTypes.AddPrivateComment,
                            "ActionTarget": null,
                            "ActionValue": "Ticket was marked as solved by the customer",
                            "Active": true
                        }
                    ]
                },
                {
                    Name: "Urgent Request",
                    AccessGuid: "",
                    Active: true,
                    Enabled: true,
                    Description: "A customer has an urgent request that needs attention",
                    ReturnURL: "",
                    BorderColor: "#666666",
                    BackgroundColor: "#ff0000",
                    Text: "Urgent!",
                    TextColor: "#ffffff",
                    TextFont: "Arial",
                    TextBold: true,
                    TextItalic: false,
                    Radius: 10,
                    Actions:
                        [
                            {
                                "ActionType": ActionTypes.UpdateField,
                                "ActionTarget": "360009119054",
                                "ActionValue": "Urgent",
                                "Active": true
                            },
                            {
                                "ActionType": ActionTypes.AddPublicComment,
                                "ActionTarget": null,
                                "ActionValue": "This is urgent please help immediately",
                                "Active": true
                            }
                        ]
                },
                {
                    Name: "Spanish Language",
                    AccessGuid: "",
                    Active: true,
                    Enabled: true,
                    Description: "This customer requests to be communicated with in Spanish",
                    ReturnURL: "",
                    BorderColor: "#666666",
                    BackgroundColor: "#0000ff",
                    Text: "Español",
                    TextColor: "#ffffff",
                    TextFont: "Arial",
                    TextBold: true,
                    TextItalic: false,
                    Radius: 10,
                    Actions:
                        [
                            {
                                "ActionType": ActionTypes.AddTag,
                                "ActionTarget": null,
                                "ActionValue": "spanish",
                                "Active": true
                            },
                            {
                                "ActionType": ActionTypes.AddPrivateComment,
                                "ActionTarget": null,
                                "ActionValue": "Customer has requested to be communicated with in Spanish",
                                "Active": true
                            }
                        ]
                }
            ]

        },
        methods: {
            doAuth: function (e) {
                vm.showPostApprove = true;
                //var aWin = window.open("about:blank", "aWin_klick-zen-auth");
                var oState = new Object(); // holds basics of user and their zendesk info
                oState.ZendeskUserID = user.id;
                oState.Name = user.name;
                oState.Email = user.email;
                oState.HasUsedTrial = vm.agreeFreeTrial;
                client.context().then(function (context) {
                    OAUTH_URL = context.account.subdomain;
                    oState.APIRoot = OAUTH_URL;
                    var state = JSON.stringify(oState);
                    window.location.href = "https://" + OAUTH_URL + ".zendesk.com/oauth/authorizations/new?response_type=code&redirect_uri=" + API_URL + "%2Fauth%2FZendesk_Decision&client_id=" + OAUTH_NAM + "&scope=read%20write&state=" + state;
                    // hide button, show text "Authorization pending..."     
                });

            },
            doShowSection: function (sec) {
                if (!vm.auth) {
                    vm.showSection = "authorize";
                }
                else {
                    //let allow = false;
                    if (vm.editMode === true) {
                        Swal.fire({
                            title: 'Exit editing without saving changes?',
                            showCancelButton: true,
                            animation: false,
                            allowOutsideClick: false,
                            confirmButtonColor: '#3085d6',
                            cancelButtonColor: '#d33',
                            confirmButtonText: 'OK'
                        }).then((result) => {
                            if (result.value) {
                                this.editMode = false;
                                vm.showSection = sec;
                            }
                        });
                    }
                    else {
                        vm.showSection = sec;
                    }
                }
            },
            doTrial: function () {
                vm.viewSaving = true;
                axios
                    .post('/functions/KlickZenTrial.ashx')
                    .then(function (d) {

                        if (d.data.activated === true) {
                            doGoodSavePopup(vm);
                            clearTrialWin(vm);
                        }
                        else {
                            doBadSavePopup(vm);
                        }
                    })
                    .catch(function (e) {
                        // save failure
                        logError(e.message);
                        doBadSavePopup(vm, e.message === UnAuthMessage);
                    });
            },
            saveCustomerData: function (closeWin) {
                if (!vm.dataUnchanged) {
                    vm.viewSaving = true;
                    axios
                        .post('/functions/KlickZenCustomer.ashx', vm.cust)
                        .then(function (d) {
                            // save success
                            vm.cust_RESET = JSON.parse(JSON.stringify(vm.cust));
                            delayedSetDataUnchanged(vm, true);
                            doGoodSavePopup(vm, closeWin);
                        })
                        .catch(function (e) {
                            // save failure
                            logError(e.message);
                            if (e.message === PreconditionError) {
                                vm.viewSaving = false;
                                Swal.fire({
                                    title: '',
                                    html: '<b>Your DNS entries did not successfully validate</b><br/><br/>Please ensure that you have properly updated your DNS records and try again',
                                    timer: 7000,
                                    animation: false 
                                });
                            }
                            else {
                                doBadSavePopup(vm, e.message === UnAuthMessage);
                            }
                        });
                }

            },
            cancelCustomerData: function () {
                if (vm.dataUnchanged) {
                    vm.showSection = vm.defaultScreen;
                }
                else {
                    Swal.fire({
                        title: 'Exit editing without saving changes?',
                        showCancelButton: true,
                        animation: false,
                        allowOutsideClick: false,
                        confirmButtonColor: '#3085d6',
                        cancelButtonColor: '#d33',
                        confirmButtonText: 'OK'
                    }).then((result) => {
                        if (result.value) {
                            this.editMode = false;
                            if (!vm.dataUnchanged) {
                                vm.cust = JSON.parse(JSON.stringify(vm.cust_RESET));

                            }
                            vm.showSection = vm.defaultScreen;
                            delayedSetDataUnchanged(vm, true);
                        }
                    });
                }
            },
            resetDefault: function () {
                vm.cust.DefaultButton = JSON.parse(JSON.stringify(vm.defaultButtonTemplate));
            },
            startButtonCreate: function (buttonTemplate) {

                if (vm.thisExecutionMode === vm.V_LITE && vm.buttons.length >= initVars().FreeVersionLimit) {
                    Swal.fire({
                        title: '',
                        html: 'You have reached the maximum amount of buttons available in the free version of Klick-Zen',
                        timer: 5000,
                        animation: false
                    });
                    return;
                }

                vm.newButton = buttonTemplate ? JSON.parse(JSON.stringify(buttonTemplate)) : JSON.parse(JSON.stringify(vm.cust.DefaultButton));
                // if this was an existing actual button, update the title
                if (vm.newButton.AccessGuid) {
                    vm.newButton.Name += " - copy";
                }
                vm.newButton.AccessGuid = ""; // important so that a new button is created
                vm.doShowSection("makeButton");
                vm.editMode = true;
                window.setTimeout(function () { document.getElementById("txtButtonName").select(); vm.editModeDataChanged = buttonTemplate ? true : false; }, 100);
            },
            buttonSave: function () {
                vm.viewSaving = true;
                axios
                    .post('/functions/KlickZenButton.ashx', vm.newButton)
                    .then(function (d) {
                        // save success
                        vm.editMode = false;
                        refreshButtons();
                        vm.doShowSection("listButtons");
                        //delayedSetDataUnchanged(vm, true);
                        doGoodSavePopup(vm);
                    })
                    .catch(function (e) {
                        // save failure
                        logError(e.message);
                        doBadSavePopup(vm, e.message === UnAuthMessage);
                    });
            },
            cancelButtonCreate: function () {
                if (vm.editModeDataChanged) {
                    Swal.fire({
                        title: 'Exit editing without saving changes?',
                        showCancelButton: true,
                        animation: false,
                        allowOutsideClick: false,
                        confirmButtonColor: '#3085d6',
                        cancelButtonColor: '#d33',
                        confirmButtonText: 'OK'
                    }).then((result) => {
                        if (result.value) {
                            this.editMode = false;
                            this.doShowSection("listButtons");
                        }
                    });
                }
                else {
                    this.editMode = false;
                    this.doShowSection("listButtons");
                }
            },
            uploadImage: function (e) {
                var files = e.target.files;
                if (files[0]) {
                    if (files[0].size > 3145728) {
                        // too big (3 MB)
                        doBadSavePopup(vm, false);
                    }
                    else {
                        var reader = new FileReader();
                        reader.readAsDataURL(files[0]);
                        reader.onload = (e) => {
                            vm.cust.DefaultLandingPage.Logo = e.target.result;
                        };
                    }

                }
            },
            addButtonAction: function () {
                if (this.newButton.Actions.length < 6) {
                    this.newButton.Actions.push({ ActionType: "", ActionTarget: "", ActionValue: "", Active: true });
                }
            },
            addActionDisabled: function () {
                return this.newButton.Actions.length >= 6 || this.newButton.Actions.some(act => !act.ActionType || !act.ActionValue);
            },
            removeButtonAction: function (w) {
                this.newButton.Actions = arrayRemove(this.newButton.Actions, w);
            },
            editButton: function (b) {
                vm.newButton = JSON.parse(JSON.stringify(b)); // parse is done as a way of cloning, otherwise this is a direct reference
                vm.doShowSection("makeButton");
                vm.editMode = true;
                window.setTimeout(function () { vm.editModeDataChanged = false; }, 100);
            },
            removeButton: function (b) {
                Swal.fire({
                    title: 'Permanently remove button "' + b.Name + '"?',
                    showCancelButton: true,
                    animation: false,
                    allowOutsideClick: false,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'OK'
                }).then((result) => {
                    if (result.value) {
                        vm.newButton = b;
                        vm.newButton.Active = false;
                        vm.buttonSave();
                    }
                });
            },
            actionValueTitle: function (actValue) {
                let retVal = "";
                switch (actValue) {
                    case ActionTypes.UpdateField: retVal = "New Field Value"; break;
                    case ActionTypes.SetStatus: retVal = "New Status"; break;
                    case ActionTypes.AddPrivateComment: retVal = "Comment"; break;
                    case ActionTypes.AddPublicComment: retVal = "Comment"; break;
                    case ActionTypes.AddTag: retVal = "Tag Name"; break;
                }
                return retVal;
            },
            fullButtonPlaceholderText: function (butt) {
                let domain = vm.customDomainToUse();
                domain = "https://" + domain + "/";
                return "<a href='" + domain + "ext/href/" + butt.AccessGuid + "/{{ticket.id}}/{{ticket.requester.id}}/{{ticket.created_at_with_timestamp}}'><img src='" + domain + "ext/src/" + butt.AccessGuid + "/{{ticket.id}}' /></a>";
            },
            customDomainToUse: function () {
                return vm.cust_RESET.CustomCNameDomain === "" ? window.location.hostname : vm.cust.CustomCNameDomain;
            },
            previewButtonStyle: function (butt) {
                var retStyle = "color:" + butt.TextColor + ";";
                retStyle += "background-color:" + butt.BackgroundColor + ";";
                retStyle += "border-radius:" + butt.Radius + "px;";
                retStyle += "border: 2px solid " + butt.BorderColor + ";";
                retStyle += "font-family: " + butt.TextFont + ";";
                retStyle += "font-style: " + (butt.TextItalic ? "italic" : "normal") + ";";
                retStyle += "font-weight: " + (butt.TextBold ? "bold" : "normal") + ";";
                let fW = butt.Text.length + 8;
                fW = fW < 12 ? 12 : fW;
                retStyle += "width: " + fW + "ch;";
                return retStyle;
            },
            overlayColor: function (color) {
                //if only first half of color is defined, repeat it
                if (color.length < 5) {
                    color += color.slice(1);
                }
                if (color.length === 6) {
                    color = "#" + color;
                }
                return color.replace('#', '0x') > 0xeeeeee ? '#333' : '#fff';
            },
            spaceClean: function (val) {
                if (val) {
                    return val.replace(/ /g, "_").toLowerCase();
                }
                else {
                    return "";
                }
            }
        },
        watch: {
            "cust": {
                handler: function (n, o) {
                    this.dataUnchanged = false;
                    this.validSettings =
                        ((this.cust.DefaultPostActionURL === "" || this.cust.DefaultPostActionURL.isValidURL()) &&
                        (this.customDomainIsValid || this.cust.CustomCNameDomain === ""));
                },
                deep: true
            },
            "newButton": {
                handler: function (n, o) {
                    this.editModeDataChanged = true;
                    this.validCreateButtonForm = this.newButton.Name !== "" && this.newButton.Text !== "" && (this.newButton.ReturnURL === "" || this.newButton.ReturnURL.isValidURL()) && this.newButton.Actions.find(u => u.ActionType);
                },
                deep: true
            }
        },
        computed: {
            enabledButtons: function () {
                return this.buttons.filter(u => u.Enabled);
            },
            customDomainTLD: function () {
                let aFullDomain = this.cust.CustomCNameDomain.split(".");
                let retTLD = "";
                let TLDlen = aFullDomain.length;
                if (TLDlen >= 2) {
                    retTLD = aFullDomain[TLDlen - 2] + "." + aFullDomain[TLDlen - 1];
                }
                return retTLD;
            },
            customDomainIsValid: function () {
                // check for at least three parts
                // pre-flight check more performant than constantly
                // validating domain
                let aFullDomain = this.cust.CustomCNameDomain.split(".");
                if (aFullDomain.length > 2 && !aFullDomain.includes(undefined) && !aFullDomain.some(f => f.includes(":") || f.includes("/"))){
                    let thisDom = tldjs.parse(this.cust.CustomCNameDomain);
                    return thisDom.isValid && !thisDom.isIp && thisDom.subdomain !== "" && thisDom.tldExists;
                }
                else {
                    return false;
                }

                
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

        client.get('currentUser').then(function (data) {
            user = data['currentUser'];
            vm.userIsAdmin = user.role === "admin" || user.role === "owner";

            // show tour if they haven't seen it already
            // check localstorage for extra fallback

            /*
            if (vm.cust.HasViewedTour === false && !localStorage.getItem("HasViewedTour") && vm.userIsAdmin) {
                window.setTimeout("startTour()", 8000);
                vm.cust.HasViewedTour = true;
                localStorage.setItem("HasViewedTour", true);
                // update this customer that they have viewed the tour
                axios.post('/functions/GitZenCustomer.ashx', vm.cust);
            }
            */

            refreshButtons();
            vm.doShowSection(vm.defaultScreen);
            // v-cloak is not enough
            window.setTimeout(function () {
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = '.popSection { display: inline }';
                document.getElementsByTagName('head')[0].appendChild(style);
            }, 100);

        });

        // get available fields, populate vm.availableTicketFields
        let options = {
            url: '/api/v2/ticket_fields.json',
            type: 'GET'
        };

        client.request(options).then((results) => {
            for (let fld of results.ticket_fields) {
                if (fld.active && fld.title !== "Status" && fld.title !== "Subject" && fld.title !== "Description") {
                    vm.availableTicketFields.push({ id: fld.id, title: fld.title });
                }
            }
        });


    });


    function refreshButtons() {
        return new Promise((resolve, reject) => {
            axios
                .get('/functions/KlickZenListButtons.ashx')
                .then(function (d) {
                    if (d.data.length) {
                        vm.buttons = d.data;
                    }
                    else {
                        vm.buttons = [];
                    }
                    resolve(d);
                })
                .catch(function (e) {
                    reject(e);
                });
        });
    }


    function delayedShowSection(tvm, section) {
        window.setTimeout(function () { tvm.showSection = section; }, 100);
    }



    function delayedSetDataUnchanged(tvm, state) {
        window.setTimeout(function () { tvm.dataUnchanged = state; }, 100);
    }

    function doGoodSavePopup(tvm, autoClose) {
        autoClose = autoClose || false;
        tvm.viewSaving = false;
        tvm.viewGoodSave = true;
        var dly = 2000;
        window.setTimeout(function () { tvm.viewGoodSave = false; }, dly);
        if (autoClose) {
            window.setTimeout(function () { tvm.showSection = tvm.defaultScreen; }, dly + 1);
        }
    }
    function doBadSavePopup(tvm, reload) {
        reload = reload || false;
        tvm.viewSaving = false;
        tvm.viewBadSave = true;
        window.setTimeout(function () {
            if (reload) {
                window.location.reload(true);
            }
            else {
                tvm.viewBadSave = false;
            }
        }, 2000);
    }

    function clearTrialWin(tvm) {
        window.setTimeout(function () {
            tvm.thisExecutionMode = tvm.V_TRIALFULL;
            //tvm.isFullVersion = true;
            tvm.doShowSection('trialComplete');
        }, 1200);
    }


    function logError(errMsg) {
        if (isLocalDev) {
            console.log(errMsg);
        }
        else {
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
}