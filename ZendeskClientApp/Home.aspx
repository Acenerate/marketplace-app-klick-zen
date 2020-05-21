<%@ Page Language="VB" %>
<!DOCTYPE html>
<script runat="server">
    Dim custObj As String = "{}"
    Dim custButtons As String = "[]"
    Dim PreCheckAuth As String = "true"
    Dim customer_subdomain As String = String.Empty
    Dim AppExecutionMode As String = KlickZen.KlickZenCustomer.AppExecutionModes.LITE
    Dim TrialDaysRemaining As Integer = 0
    Dim hasUsedTrial As String = "false"
    Dim JwtToken As String = ""
    Dim showReviewReminder As String = "false"

    ' ********************************
    ' *** IMPERSONATION ***
    ' * DO NOT USE IN STAGE *
    ' * IT WILL KILL THE USER's *
    ' * EXISTING TOKEN *
    Const TEST_MIMIC As String = ""
    Dim TEST_MODE As Boolean = False
    Const TEST_MASTER As String = "d3v-git-zen"
    ' ********************************





    Sub _ini(sender As Object, e As EventArgs) Handles Me.Init
        ' load user based on the GUID that was passed or on the zendesk auth
        Dim ExistingCustomer As KlickZen.KlickZenCustomer

        If Not Request("token") = Nothing Then
            ' use the zendesk auth
            Dim token As String = Context.Request("token")
            ' this is just a security AUTH; customer should already exist at this point

            ' decode the token
            ' https://developer.zendesk.com/apps/docs/developer-guide/using_sdk#authenticating-zendesk-in-your-server-side-app

            Dim Out As KlickZen.ZenDeskAPI.JWT
            Try
                Dim outJWT As String = Decrypto.Decode(token, KlickZen.Config.ZendeskAppPublicKey, KlickZen.Config.ValidateAppPublicKey)
                Out = Newtonsoft.Json.JsonConvert.DeserializeObject(Of KlickZen.ZenDeskAPI.JWT)(outJWT)
            Catch ex As Exception
                KlickZen.PublicFunctions.Logging.Log(ex.Message)
                Response.End()
            End Try

            ' also verify timestamp
            Dim Expires As New DateTime(1970, 1, 1, 0, 0, 0)
            Expires = Expires.AddSeconds(Out.exp)

            If DateDiff(DateInterval.Second, Expires, Now) > 0 Then
                ' token is expired
                KlickZen.PublicFunctions.Logging.Log("Expired token")
                Response.End()
            End If

            customer_subdomain = Replace(Out.iss, ".zendesk.com", "")

            ' *****************
            ' *  BLACKLIST    *
            ' *****************
            ' if this is a recurring "issue" customer, then activate blacklist response
            Dim BLACKLIST As New List(Of String)
            BLACKLIST.Add("mvnxvoice")
            BLACKLIST.Add("integratecloud")
            BLACKLIST.Add("tissueapp")


            If BLACKLIST.Contains(customer_subdomain) Then
                Response.Write("<p style='font-family:arial'>There is an issue with your account; please contact support:<br/><br/><a href='mailto:support@git-zen.com?subject=Internal account issue'>support@git-zen.com</a></p>")
                Response.End()
            End If
            ' *****************

            If customer_subdomain = TEST_MASTER And Not String.IsNullOrEmpty(TEST_MIMIC) Then
                TEST_MODE = True
                customer_subdomain = TEST_MIMIC
            End If

            ' load by the subdomain
            If (Not String.IsNullOrEmpty(customer_subdomain)) Then
                ExistingCustomer = KlickZen.KlickZenCustomer.LoadByZendeskURL(customer_subdomain)
            End If



        End If

        ' if nothing loaded... then we're done.
        If ExistingCustomer Is Nothing Then
            ' KlickZen.PublicFunctions.Logging.Log("Settings attempted access, but wrong information passed: " & customer_subdomain, KlickZen.PublicFunctions.Logging.LogType.ERROR)
            '  Response.End()
            ' ask customer to (re)-authorize
            PreCheckAuth = "false"
        Else
            ' need to validate the Zendesk oAuth token here!  just cause customer exists does not mean
            ' that they have a valid token
            If (ExistingCustomer.ZendeskLiteralToken Is Nothing OrElse String.IsNullOrEmpty(ExistingCustomer.ZendeskLiteralToken.token.id)) And (Not KlickZen.Config.DebugOn) Then
                PreCheckAuth = "false"
                KlickZen.PublicFunctions.Logging.Log("Could not load literal token for " & customer_subdomain, KlickZen.PublicFunctions.Logging.LogType.ERROR)
            Else

                ' instead of session, we are now just using JWTs
                ' passed with each AXIOS request for security
                JwtToken = ExistingCustomer.JWTGenerate

                ' if we got this far on this page, but the DB still has then plan DISABLED,
                ' then there obviously is a lag with the check; re-check this user
                If ExistingCustomer.Plan = KlickZen.KlickZenCustomer.PlanTier.Disabled Then
                    Select Case ExistingCustomer.APIRoot
                        Case "xxxd3v-git-zen"
                            ' leave alone by default
                            ' *** TEST
                            'AppExecutionMode = KlickZen.KlickZenCustomer.AppExecutionModes.LITE
                            'ExistingCustomer.HasUsedTrial = False
                            'AppExecutionMode = KlickZen.KlickZenCustomer.AppExecutionModes.TRIALFULL
                            'AppExecutionMode = KlickZen.KlickZenCustomer.AppExecutionModes.FULL
                            ' ***
                        Case Else
                            ExistingCustomer.SetAppPlan()
                    End Select
                End If

                ' if they are STILL DISABLED, then just STOHPPP
                If ExistingCustomer.AppExecutionMode = KlickZen.KlickZenCustomer.AppExecutionModes.DISABLED Then
                    Response.End()
                End If


                'KlickZen.PublicFunctions.Logging.Log("Success authorizing " & customer_subdomain, KlickZen.PublicFunctions.Logging.LogType.INFORMATION)


                ' also, only show review reminder occasionally
                Select Case Today.Date.Day
                    Case 2, 10, 18, 26
                    Case Else
                        showReviewReminder = "false"
                End Select

                AppExecutionMode = ExistingCustomer.AppExecutionMode




                hasUsedTrial = ExistingCustomer.HasUsedTrial.ToString.ToLower
                TrialDaysRemaining = ExistingCustomer.TrialDaysRemaining.ToString

                custObj = Newtonsoft.Json.JsonConvert.SerializeObject(ExistingCustomer)
                custButtons = Newtonsoft.Json.JsonConvert.SerializeObject(ExistingCustomer.ActionButtons)

            End If

        End If



        custObj = Convert.ToBase64String(System.Text.ASCIIEncoding.ASCII.GetBytes(custObj))
        custButtons = Convert.ToBase64String(System.Text.ASCIIEncoding.ASCII.GetBytes(custButtons))

    End Sub


</script>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Klick-Zen</title>
        <script src="https://static.zdassets.com/zendesk_app_framework_sdk/2.0/zaf_sdk.min.js"></script>
        <script>
            function initVars() {
                return {
                    PreCheckAuth: <%=PreCheckAuth%>,
                    FreeVersionLimit: <%=KlickZen.Config.FreeVersionLimit%>,
                    custObj: oXXil("<%=custObj%>"),
                    custButtons: oXXil("<%=custButtons%>"),
                    useageA: "<%=KlickZen.Config.App_ID_Paid%>",
                    useageB: "<%=KlickZen.Config.App_ID_Paid_local%>",
                    executionMode: <%=AppExecutionMode%>,
                    hasUsedTrial: <%=hasUsedTrial%>,
                    JwtToken: "<%=JwtToken%>"
                }
            }
        </script>

        <script defer src="https://cdn.jsdelivr.net/npm/vue@2.6.11/dist/vue.min.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/axios@0.19.2/dist/axios.min.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/sweetalert2@9.10.12/dist/sweetalert2.all.min.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/vue-multiselect@2.1.6/dist/vue-multiselect.min.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/turndown@5.0.3/dist/turndown.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/intro.js@2.9.3/intro.min.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/tldjs@2.3.1/tld.min.js"></script>
        <script defer src="js/min/functions.<%=KlickZen.Config.CurrentAppVersion%>.js"></script>
        <script defer src="js/min/klick-zen.<%=KlickZen.Config.CurrentAppVersion%>.js" charset="utf-8"></script>
        <script defer src="js/min/klick-zen-tour.<%=KlickZen.Config.CurrentAppVersion%>.js"></script>
        
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/combine/npm/@zendeskgarden/css-bedrock@7.0.8/dist/index.min.css,npm/@zendeskgarden/css-buttons@6.1.0/dist/index.min.css,npm/@zendeskgarden/css-forms@6.1.1/dist/index.min.css,npm/@zendeskgarden/css-utilities@3.1.1/dist/index.min.css,npm/@zendeskgarden/css-callouts@3.1.1/dist/index.min.css,npm/@zendeskgarden/css-tags@4.1.2/dist/index.min.css,npm/@zendeskgarden/css-tags@4.1.2/dist/index.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/vue-multiselect@2.1.6/dist/vue-multiselect.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/intro.js@2.9.3/introjs.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/intro.js@2.9.3/themes/introjs-dark.css">
        <link rel="stylesheet" href="css/tooltip.min.css">
        <link rel="stylesheet" href="css/sidebarRoot.min.<%=KlickZen.Config.CurrentAppVersion%>.css">
        <link rel="stylesheet" href="css/klick-zen.min.<%=KlickZen.Config.CurrentAppVersion%>.css">
        
    </head>
    <body>
        <div id="app" class="pane_container">

            <!-- SIDE MENU -->
            <div v-cloak v-if="auth" class="pane">
                <div class="title">Buttons</div>
                <ul class="nav nav-pills nav-stacked">
                    <li class="ember-view"><a href="#" @click="doShowSection('listButtons')">Available KlickButtons</a></li>
                    <template v-cloak v-if="thisExecutionMode===V_LITE">
                        <!-- <li class="ember-view"><a href="#" @click="doShowSection('buttonMetrics')">KlickButton Metrics</a></li> -->
                        <li class="ember-view"><a href="#" class="full-only">Default Button Template</a></li>
                        <li class="ember-view"><a href="#" class="full-only">Custom Landing Page</a></li>
                    </template>
                    <template v-cloak v-else>
                        <!-- <li class="ember-view"><a href="#" @click="doShowSection('buttonMetrics')">KlickButton Metrics</a></li> -->
                        <li class="ember-view"><a href="#" @click="doShowSection('buttonDefaults')">Default Button Template</a></li>
                        <li class="ember-view"><a href="#" @click="doShowSection('landingPage')">Custom Landing Page</a></li>
                    </template>
                </ul>
                <div class="title">System</div>
                <ul class="nav nav-pills nav-stacked">
                    <template v-cloak v-if="thisExecutionMode===V_LITE">
                        <li class="ember-view"><a href="#" class="full-only">Settings</a></li>
                    </template>
                    <template v-cloak v-else>
                        <li class="ember-view"><a href="#" @click="doShowSection('settings')">Settings</a></li>
                    </template>
                    <li class="ember-view"><a href="#" @click="doShowSection('help')">Help</a></li>
                    <li class="ember-view"><a href="mailto:support@klick-zen.com?subject=Application Support">Contact Support</a></li>
                </ul>
            </div>
            <div class="pane" v-cloak v-else>
                <!-- THIS IS THE EMPTY SIDE MENU FOR WHEN THERE IS NO AUTH -->
            </div>


            <!-- MAIN WINDOW -->
            <div class="pane">







                    <!-- SETUP -->
                    <div v-cloak v-if="showSection==='authorize'" class="popSection">
                        <h2>{{appName}} Setup</h2>
                        <div class="half-section center-me">
                            
                            <div>
                                In order to integrate Zendesk with {{appName}}, 
                                we must first allow {{appName}} access to <b><i><%=customer_subdomain %></i></b>. Please
                                agree to the <a target="_tos" href="https://www.klick-zen.com/terms">Terms of Service</a>, and then
                                click "Authorize".
                            </div>
                            <div>
                                <button v-on:click="doAuth" :disabled="!agreeTOS" class="c-btn c-btn--primary">AUTHORIZE</button>
                            </div>
                            <div class="c-chk u-mb-xs">
                                <input v-model="agreeTOS" class="c-chk__input" id="tosser" type="checkbox">
                                <label class="c-chk__label c-chk__label--regular" for="tosser"><span style="font-size:.8em;font-weight:bold;">I agree to the {{appName}} <a target="_tos" href="https://www.klick-zen.com/terms">Terms of Service</a></span></label>
                            </div>
                            <div>
                                After successful authorization,
                                please refresh your browser window
                                to complete the activation process.
                            </div>
                            <div v-cloak v-if="isFullVersion==false" style="border:2px solid #1f73b7;padding:3px;border-radius:6px;">
                                The 
                                <a href="https://www.zendesk.com/apps/support/klick-zen/" target="_market">full version of {{appName}}</a>
                                offers multiple button definitions, customizable landing pages, and much more! 
                                <br/>
                                <input v-model="agreeFreeTrial" class="c-chk__input" id="prefree" type="checkbox">
                                <label class="c-chk__label c-chk__label--regular" for="prefree"><span style="font-size:.8em;font-weight:bold;">Activate 14-day FREE TRIAL of the full version</span></label>
                            </div>
                        </div>

                    </div>

































                    <!-- BUTTON DEFAULTS -->
                    <div v-cloak v-if="showSection=='buttonDefaults'" class="popSection">
                        <h2 :class="thisExecutionMode===V_TRIALFULL ? 'full-only-warn' : ''">Button Defaults</h2>
                        <div>
                            <small class="c-txt__hint u-fs-sm">When you create a new button from scratch, these settings are used as a base template</small>
                        </div>
                        <div>
                            <div class="c-txt">
                                <label class="c-txt__label">Button Appearance</label>
                            </div>
                            <div>
                                <input type="text" class="buttonPreview" :style="previewButtonStyle(cust.DefaultButton)" v-model="cust.DefaultButton.Text" maxlength="25" placeholder="Button Text" disabled="disabled" />
                                <!--<br /><small class="c-txt__hint u-fs-sm">(preview of how button will appear)</small>-->
                            </div>
                            <div>
                                <span class="spaceLeft">
                                    <input v-model="cust.DefaultButton.TextBold" class="c-chk__input" id="nbBold" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="nbBold">Bold</label>
                                </span>
                                <span class="spaceLeft">
                                    <input v-model="cust.DefaultButton.TextItalic " class="c-chk__input" id="nbItalic" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="nbItalic">Italic</label>
                                </span>
                                <span class="spaceLeft">
                                    <select v-model="cust.DefaultButton.TextFont" class="c-txt__input c-txt__input--select u-1/5">
                                        <option value="Arial">Arial</option>
                                        <option value="Bookman">Bookman</option>
                                        <option value="Courier">Courier</option>
                                        <option value="Garamond">Garamond</option>
                                        <option value="Georgia">Georgia</option>
                                        <option value="Impact">Impact</option>
                                        <option value="Palatino">Palatino</option>
                                        <option value="Times">Times</option>
                                        <option value="Trebuchet MS">Trebuchet MS</option>
                                        <option value="Verdana">Verdana</option>
                                    </select>
                                </span>
                            </div>
                            <div>
                                <label class="c-txt__label spaceLeft">Border </label><input type="color" class="c-txt__input u-1/12" v-model="cust.DefaultButton.BorderColor" />
                                <label class="c-txt__label spaceLeft">Background </label><input type="color" class="c-txt__input u-1/12" v-model="cust.DefaultButton.BackgroundColor" />
                                <label class="c-txt__label spaceLeft">Text </label><input type="color" class="c-txt__input u-1/12" v-model="cust.DefaultButton.TextColor" />
                            </div>

                            <div class="c-txt u-1/3">
                                <label class="c-range__label c-txt__label spaceLeft" for="range-7">Roundness</label>
                                <input class="c-range__input spaceLeft" id="range-7" step="1" min="1" max="20" type="range" v-model="cust.DefaultButton.Radius" :style="'background-size: ' + (100 * (parseInt(cust.DefaultButton.Radius) - 1) / (20 - 1)).toString() + '%;'" />
                            </div>

                            <div class="c-txt">
                                <label class="c-txt__label">Button Functionality</label>
                                <!--<small class="c-txt__hint u-fs-sm">
                                    When Klickbutton is not enabled, the button image will appear "greyed out" when
                                    viewed, and no action will be taken when it is clicked on. The button will not be 
                                    available in the ticket editor.
                                </small>-->
                                <div>
                                    <input v-model="cust.DefaultButton.Enabled" class="c-chk__input" id="cuENB" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="cuENB">Button Enabled</label>
                                </div>
                                <div v-cloak v-if="globalTrackingEnabled">
                                    <input v-model="cust.DefaultButton.Tracking" class="c-chk__input" id="cuTRK" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="cuTRK">Tracking Enabled</label>
                                </div>
                            </div>

                            <div class="bottom-button-padding">
                                <button class="c-btn c-btn--muted" @click="resetDefault">Reset</button>
                                <button class="c-btn c-btn--primary c-btn--danger" @click="cancelCustomerData" :disabled="viewSaving || viewGoodSave || viewBadSave">Cancel</button>
                                <button v-on:click="saveCustomerData" :disabled="dataUnchanged" class="c-btn c-btn--primary">Update</button>
                            </div>
                        </div>


                    </div>








                    <!-- LANDING PAGE -->
                    <div v-cloak v-if="showSection=='landingPage'" class="popSection">
                        <h2 :class="thisExecutionMode===V_TRIALFULL ? 'full-only-warn' : ''">{{appName}} Custom Landing Page</h2>
                        <div>
                            <small class="c-txt__hint u-fs-sm">
                                The landing page is a web page where your customer is directed
                                after they click on a KlickButton; it lets them know that the
                                action that they took has completed.  You may specify a different landing page
                                URL for each button, or set a global one in your settings.
                                When no landing page URL is specified for a button, a "default" landing page is shown
                                to an end user after they take action via a button.
                                You may alter the settings below to customize the appearance of this page.
                            </small>
                        </div>
                        <div>
                            <button class="c-btn c-btn--sm c-btn--pill" :disabled="!dataUnchanged" v-on:click="window.open('https://' + customDomainToUse() + '/DefaultLanding/' + cust.AccessGUID, 'kz-preview');">Preview landing page</button>
                        </div>
                        <div>
                            <div class="c-txt">
                                <label class="c-txt__label">HTML Browser Title</label>
                                <small class="c-txt__hint u-fs-sm">
                                    Shown in the title bar of the web browser tab
                                </small>
                                <input type="text" class="c-txt__input u-2/3" v-model="cust.DefaultLandingPage.CompanyName" maxlength="255" :placeholder="cust.APIRoot" />
                            </div>
                            <div class="c-txt">
                                <label class="c-txt__label">Template Colors</label>
                                <small class="c-txt__hint u-fs-sm">
                                    Used to highlight the page; often matches your corporate color scheme
                                </small>
                                <div>
                                    <label class="c-txt__label spaceLeft">Brand Color: </label><input type="color" class="c-txt__input u-1/12" v-model="cust.DefaultLandingPage.DarkColor" />
                                    <label class="c-txt__label spaceLeft">Accent Color: </label><input type="color" class="c-txt__input u-1/12" v-model="cust.DefaultLandingPage.LightColor" />
                                </div>
                            </div>
                            <div class="c-txt">
                                <label class="c-txt__label">Page Header Image</label>
                                <small class="c-txt__hint u-fs-sm">
                                    Can be any image, often is a corporate logo to maintain consistent identity
                                    for the user experience; limited to 3 MB file size
                                </small>
                                <img :src="cust.DefaultLandingPage.Logo" class="template-image-preview" />
                                <button class="c-btn c-btn--sm c-btn--pill fileContainer">
                                    Select new image
                                    <input class="xcustom-file-input" type="file" accept="image/*" @change="uploadImage" />
                                </button>
                                
                            </div>
                            <div class="c-txt">
                                <label class="c-txt__label">Page Content (in Markdown format)</label>
                                <small class="c-txt__hint u-fs-sm">
                                    Anything that you'd like to say to your end user after they have completed
                                    the button submission; this can include a link back to your support or corporate
                                    website
                                </small>
                                <textarea class="c-txt__input c-txt__input--area u-2/3" style="height:250px;" v-model="cust.DefaultLandingPage.PageContent"></textarea>
                                    <div style="margin-top:6px;font-size:8pt;display:flex;justify-content:space-between;">
                                        <a class="c-btn--pill c-btn--basic c-btn--muted tooltip-bottom c-btn--muted-enabled" target="_markdown" href="https://www.markdownguide.org/basic-syntax">
                                            <svg style="margin-right:4px;" class="c-btn__icon" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M14.85 3H1.15C.52 3 0 3.52 0 4.15v7.69C0 12.48.52 13 1.15 13h13.69c.64 0 1.15-.52 1.15-1.15v-7.7C16 3.52 15.48 3 14.85 3zM9 11H7V8L5.5 9.92 4 8v3H2V5h2l1.5 2L7 5h2v6zm2.99.5L9.5 8H11V5h2v3h1.5l-2.51 3.5z"></path></svg>Need help with Markdown syntax?
                                        </a>
                                    </div>
                            </div>

                            <div class="bottom-button-padding">
                                <button class="c-btn c-btn--primary c-btn--danger" @click="cancelCustomerData" :disabled="viewSaving || viewGoodSave || viewBadSave">{{dataUnchanged ? "Close" : "Cancel"}}</button>
                                <button v-on:click="saveCustomerData(false)" :disabled="!validSettings || dataUnchanged" class="c-btn c-btn--primary">Update</button>
                                <button v-on:click="saveCustomerData(false);window.setTimeout(function(){window.open('https://' + customDomainToUse() + '/DefaultLanding/' + cust.AccessGUID, 'kz-preview');}, 1000);" :disabled="!validSettings || dataUnchanged" class="c-btn c-btn--primary">Update and Preview</button>
                            </div>
                        </div>
                    </div>








                    <!-- BUTTON METRICS -->
                    <div v-cloak v-if="showSection=='buttonMetrics'" class="popSection">
                        <h2 :class="thisExecutionMode===V_TRIALFULL ? 'full-only-warn' : ''">KlickButton Metrics</h2>
                    </div>






                    <!-- TRIAL ACTIVATION -->
                    <div v-cloak v-if="showSection==='trial'" class="popSection">
                        <h2>{{appName}} Full Version 14-day Free Trial</h2>
                        <div>
                            <p>
                                Try the full-featured subscription version of {{appName}} <b>FREE</b> for 14 days!
                                The subscription version includes all of the features of {{appName}} Lite, plus:
                            </p>
                            <ul class="proper">
                                <li>Multiple button definitions</li>
                                <li>Customizable landing page</li>
                                <li>Customizable default button template</li>
                                <li>Button cloning</li>
                                <li>Use your custom domain name</li>
                                <li>Access to system settings</li>
                                <li>Full product support</li>
                            </ul>
                            <p>
                                When you activate the trial, your installation of {{appName}} will convert in-place
                                to the full version; you will not have to perform a re-installation.
                            </p>
                            <div class="bottom-button-padding">
                                <button class="c-btn c-btn--primary" style="cursor:pointer;" @click="doTrial">Activate 14-day Trial</button>
                            </div>
                        </div>
                    </div>

                    <div v-cloak v-if="showSection==='trialComplete'" class="popSection">
                        <h2 class="c-txt__label u-mt-xs-">{{appName}} Full Version Trial Activated</h2>
                        <div>
                            <p>
                                Your 14-day trial of the full version is now activated.
                            </p>
                            <p>
                                During your trial, you will enjoy all of the features of the full version
                                of {{appName}}, including a customizable landing page and mulitple button definitions!
                            </p>
                            <p>
                                When you are ready to permanently switch to the full version,
                                simply <a href="https://www.zendesk.com/apps/support/klick-zen/" target="_market">install
                                it from the Zendesk marketplace</a>. All of your existing settings and data
                                will remain in place; you will not even need to re-authorize your Zendesk token.
                           </p>
                            <p>Thank you for trying {{appName}}!</p>
                        </div>
                    </div>







                    <!-- LIST BUTTONS -->
                    <div v-cloak v-if="showSection=='listButtons'" class="popSection">
                        <h2 style="margin-bottom:50px;"><b>{{appName}}</b>: Zendesk Customer Ticket Buttons<button :class="'c-btn c-btn--sm' + (buttons.length===0 ? ' pulse-attention' : '')" style="float:right;" type="button" @click="startButtonCreate()">Create new button</button></h2>
                        <div v-cloak v-if="buttons.length===0">
                            <p>
                                Klick-Zen allows you to quickly create functional Zendesk
                                action buttons that, when clicked by one of your end users,
                                takes an action on their ticket - such as adding a tag or setting
                                the value of a custom field.
                            </p>
                            <p>
                                These buttons can be automatically inserted into emails
                                that are sent to your end users via a trigger, or they may
                                be added manually by a Zendesk agent while creating a response
                                to a ticket.
                            </p>
                            <ol class="list-round">
                                <li>
                                    <h5>Create Buttons</h5>
                                    Click the "Create new button" button above to create a new button from scratch. You may also click on one of the below buttons
                                    to use it as a template to get started:
                                    <div>
                                        <span v-for="but in genericButtonTemplates" style="margin-right:10px;">
                                            <button @click="startButtonCreate(but)" type="button" class="c-btn c-btn--sm" :style="'border:1px solid ' + but.BorderColor + ';background-color:' + but.BackgroundColor + ';color:' + but.TextColor">{{but.Name}}</button>
                                        </span>
                                    </div>
                                </li>
                                <li>
                                    <h5>Add Buttons to Email Template</h5>
                                    When <a href="https://support.zendesk.com/hc/en-us/articles/203662106-Streamlining-workflow-with-ticket-updates-and-triggers" target="_zendeskhelp">creating a Zendesk trigger with an email response</a>,
                                    you may copy and paste the HTML for a KlickButton into a custom email template that
                                    is sent when one of your custom triggers is activated. The HTML for your
                                    KlickButton is available next to each listed button in the <a href="#" @click="doShowSection('listButtons')">KlickButtons</a>
                                    section.
                                </li>
                                <li>
                                    <h5>Insert Button in Ticket Editor</h5>
                                    When viewing a Zendesk ticket, your Zendesk agents can insert a KlickButton
                                    directly into a response by using the ticket editor button:
                                    <div><img src="img/TicketEditorSnap.png" alt="ticket editor button" /></div>
                                </li>
                            </ol>
                        </div>
                        <div v-cloak v-else>
                            <small class="c-txt__hint u-fs-sm">
                                Copy the HTML code to insert the button into a custom Zendesk email template;
                                click the "X" on the right side of the row to delete a button
                            </small>

                            <div v-for="butt in buttons" class="list-table-child trigger-condition z-card">
            
                    
                                <div>
                                    <a href="#" @click="editButton(butt);">{{butt.Name}}</a>
                                    <div style="margin:8px 0 0 0">
                                        <button class="c-tag c-tag--pill c-tag--red pill-button" @click="editButton(butt)">Edit</button>
                                        <button class="c-tag c-tag--pill c-tag--blue pill-button" @click="startButtonCreate(butt)" v-cloak v-if="thisExecutionMode!==V_LITE">Clone</button>
                                    </div>
                                </div>
                                <div><img :src="'/ext/src/' + butt.AccessGuid + '/00000-0000'" /></div>
                                <div style="position:relative;">
                                    <input v-bind:id="'but_' + butt.Id" type="text" class="c-txt__input" v-bind:value="fullButtonPlaceholderText(butt)" readonly />
                                    <div class="c-txt__input--media__figure button-copy" v-bind:data-copytarget="'#but_' + butt.Id" onclick="copy(this);">
                                        <svg>
                                        <use xlink:href="zendesk.svg#zd-svg-icon-16-clipboard-blank-fill"></use>
                                        </svg>
                                    </div>
                                </div>
                                <button class="trigger-condition__btn--remove z-card__remove-btn" type="button" @click="removeButton(butt)"></button>
                    
                
                            </div>
                            <template v-cloak v-if="thisExecutionMode!==V_LITE">
                                <hr />
                                <p>Create a new button starting with a pre-defined button template:</p>
                                <div>
                                    <span v-for="but in genericButtonTemplates" style="margin-right:10px;">
                                        <button @click="startButtonCreate(but)" type="button" class="c-btn c-btn--sm" :style="'border-radius:'  + but.Radius + 'px;border:2px solid ' + but.BorderColor + ';background-color:' + but.BackgroundColor + ';color:' + but.TextColor">{{but.Name}}</button>
                                    </span>
                                </div>
                            </template>
                        </div>
                    </div>











                    <!-- ADD/EDIT BUTTON -->
                    <div v-cloak v-if="showSection=='makeButton'" class="popSection">
                        <h2 class="editable">
                            <input id="txtButtonName" type="text" class="c-txt__input u-1/3" v-model="newButton.Name" maxlength="25" placeholder="KlickButton Name" />
                        </h2>
                        <div>
                            <div class="c-txt">
                                <label class="c-txt__label">Button Appearance</label>
                                <small class="c-txt__hint u-fs-sm">Type directly inside the button to change the text; 25 characters max</small>
                            </div>
                            <div>
                                <input type="text" class="buttonPreview" :style="previewButtonStyle(newButton)" v-model="newButton.Text" maxlength="25" placeholder="Button Text" />
                                <!--<br /><small class="c-txt__hint u-fs-sm">(preview of how button will appear)</small>-->
                            </div>
                            <div>
                                <span class="spaceLeft">
                                    <input v-model="newButton.TextBold" class="c-chk__input" id="nbBold" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="nbBold">Bold</label>
                                </span>
                                <span class="spaceLeft">
                                    <input v-model="newButton.TextItalic " class="c-chk__input" id="nbItalic" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="nbItalic">Italic</label>
                                </span>
                                <span class="spaceLeft">
                                    <select v-model="newButton.TextFont" class="c-txt__input c-txt__input--select u-1/5">
                                        <option value="Arial">Arial</option>
                                        <option value="Bookman">Bookman</option>
                                        <option value="Courier">Courier</option>
                                        <option value="Garamond">Garamond</option>
                                        <option value="Georgia">Georgia</option>
                                        <option value="Impact">Impact</option>
                                        <option value="Palatino">Palatino</option>
                                        <option value="Times">Times</option>
                                        <option value="Trebuchet MS">Trebuchet MS</option>
                                        <option value="Verdana">Verdana</option>
                                    </select>
                                </span>
                            </div>
                            <div>
                                <label class="c-txt__label spaceLeft">Border </label><input type="color" class="c-txt__input u-1/12" v-model="newButton.BorderColor" />
                                <label class="c-txt__label spaceLeft">Background </label><input type="color" class="c-txt__input u-1/12" v-model="newButton.BackgroundColor" />
                                <label class="c-txt__label spaceLeft">Text </label><input type="color" class="c-txt__input u-1/12" v-model="newButton.TextColor" />
                            </div>

                            <div class="c-txt u-1/3">
                                <label class="c-range__label c-txt__label spaceLeft" for="range-7">Roundness</label>
                                <input class="c-range__input spaceLeft" id="range-7" step="1" min="1" max="20" type="range" v-model="newButton.Radius" :style="'background-size: ' + (100 * (parseInt(newButton.Radius) - 1) / (20 - 1)).toString() + '%;'" />
                            </div>

                            <div class="c-txt">
                                <label class="c-txt__label">Button Description</label>
                                <small class="c-txt__hint u-fs-sm">For internal use, does not appear in button</small>
                                <input type="text" class="c-txt__input u-2/3" v-model="newButton.Description" maxlength="500" />
                            </div>

                            <div class="c-txt">
                                <label class="c-txt__label">Button Functionality</label>
                                <!--<small class="c-txt__hint u-fs-sm">
                                    When Klickbutton is not enabled, the button image will appear "greyed out" when
                                    viewed, and no action will be taken when it is clicked on. The button will not be 
                                    available in the ticket editor.
                                </small>-->
                                <div>
                                    <input v-model="newButton.Enabled" class="c-chk__input" id="cuENB" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="cuENB">Button Enabled</label>
                                    <div><small class="c-txt__hint u-fs-sm">When not enabled, the button will display as "greyed out"; clicking on button will not actually take action on the ticket</small></div>
                                </div>
                                <div v-cloak v-if="globalTrackingEnabled">
                                    <input v-model="newButton.Tracking" class="c-chk__input" id="cuTRK" type="checkbox">
                                    <label class="c-chk__label c-chk__label--toggle" for="cuTRK">Tracking Enabled</label>
                                    <div><small class="c-txt__hint u-fs-sm">When enabled, data will be stored that will track when the button was viewed by the user</small></div>
                                </div>
                            </div>

                            <div class="c-txt">
                                <label class="c-txt__label">Button Actions</label>
                                <small class="c-txt__hint u-fs-sm">This is what will happen to the ticket when the button is clicked; <b>you MUST have at least one action defined</b></small>
                                <div>
                                    <template v-for="act in newButton.Actions">
                                        <div class="trigger-condition z-card">
                                            <button class="trigger-condition__btn--remove z-card__remove-btn" type="button" @click="removeButtonAction(act)"></button>
                                            <!--<label class="c-txt__label spaceLeft">Action: </label>-->
                                            <select v-model="act.ActionType" class="c-txt__input c-txt__input--select u-1/4" :disabled="act.ActionType!=''">
                                                <option value="">SELECT AN ACTION:</option>
                                                <option v-bind:value="ActionTypes.UpdateField">Update Ticket Field</option>
                                                <option v-bind:value="ActionTypes.SetStatus">Set Ticket Status</option>
                                                <option v-bind:value="ActionTypes.AddPrivateComment">Add Private Comment</option>
                                                <option v-bind:value="ActionTypes.AddPublicComment">Add Public Comment</option>
                                                <option v-bind:value="ActionTypes.AddTag">Add Ticket Tag</option>
                                            </select>
                                            <template v-if="act.ActionType != ''">
                                                <template v-if="act.ActionType==ActionTypes.UpdateField">
                                                    <label class="c-txt__label spaceLeft">Field: </label>
                                                    <select v-model="act.ActionTarget" class="c-txt__input c-txt__input--select u-1/6">
                                                        <template v-for="fld in availableTicketFields">
                                                            <option v-bind:value="fld.id">{{fld.title}}</option>
                                                        </template>
                                                    </select>
                                                </template>
                                                <label class="c-txt__label spaceLeft">{{actionValueTitle(act.ActionType)}}: </label>
                                                <select v-if="act.ActionType==ActionTypes.SetStatus" v-model="act.ActionValue" class="c-txt__input c-txt__input--select u-1/4">
                                                    <option value="open">Open</option>
                                                    <option value="pending">Pending</option>
                                                    <option value="solved">Solved</option>
                                                </select>
                                                <input v-if="act.ActionType!=ActionTypes.SetStatus" type="text" class="c-txt__input u-1/3" v-model="act.ActionValue" />
                                            </template>
                                        </div>
                                        
                                    </template>
                                </div>
                                <button class="c-btn c-btn--sm" type="button" @click="addButtonAction" :disabled="addActionDisabled()">Add button action</button>
                            </div>
                            <div :class="'c-txt' + ((newButton.ReturnURL==='' || newButton.ReturnURL.isValidURL()) ? '' : ' c-txt_err')">
                                <label class="c-txt__label">Post-Action URL</label>
                                <small class="c-txt__hint u-fs-sm">
                                    This is the URL of a web page that the user is redirected to after the button action is completed; if left blank, the user will be sent to the default URL designated in your {{appName}} system settings
                                </small>
                                <input type="text" class="c-txt__input u-2/3" v-model="newButton.ReturnURL" maxlength="255" placeholder="https://www.YourCompany.com/LandingPage" />
                            </div>



                            <div class="bottom-button-padding">
                                <button class="c-btn c-btn--primary c-btn--danger" @click="cancelButtonCreate" :disabled="viewSaving || viewGoodSave || viewBadSave">Cancel</button>
                                <button v-on:click="buttonSave" :disabled="!validCreateButtonForm || !editModeDataChanged" class="c-btn c-btn--primary">{{vm.newButton.AccessGuid==""?"Create":"Update"}}</button>
                            </div>
                        </div>
                    </div>















                    <!-- SETTINGS -->
                    <div v-cloak v-if="showSection=='settings'" class="popSection">
                        <h2 :class="thisExecutionMode===V_TRIALFULL ? 'full-only-warn' : ''">{{appName}} Settings</h2>
                        <div>
                            <div class="c-txt">
                                <label class="c-txt__label">Allow KlickButtons in Ticket Editor</label>
                                <small class="c-txt__hint u-fs-sm">
                                    When enabled, Zendesk ticket agents may insert individual KlickButtons
                                    into ticket messages using the Klick-Zen message tool within the Zendesk
                                    ticket editor
                                </small>
                                <input v-model="cust.AllowTicketEditor" class="c-chk__input" id="cuATE" type="checkbox">
                                <label class="c-chk__label c-chk__label--toggle" for="cuATE">Allow editor KlickButtons</label>
                            </div>
                            <div :class="'c-txt' + ((cust.CustomCNameDomain ==='' || customDomainIsValid) ? '' : ' c-txt_err')">
                                <label class="c-txt__label">Host Mapping</label>
                                <small class="c-txt__hint u-fs-sm">
                                    Use this setting to map one of your own domain names to Klick-Zen. 
                                    For example, use klick.yourdomain.com instead of <%= klickzen.Config.KlickZenCNAMERoot %>.
                                    When populated, Klick-Zen will allow your custom domain to be
                                    used to view buttons and perform button actions, giving a more
                                    seamless appearance to your customers. HTML snippets shown within
                                    the Klick-Zen interface will be changed to reflect this URL,
                                    but Zendesk email templates will have to be manually updated to show
                                    the new value. 
                                </small>
                                <input type="text" class="c-txt__input u-1/3" v-model="cust.CustomCNameDomain" maxlength="255" placeholder="klick.yourdomain.com" />
                                <img v-if="cust_RESET.CustomCNameDomain && cust_RESET.CustomCNameDomain===cust.CustomCNameDomain" id="SSLCheckImg" :src="'https://' + cust_RESET.CustomCNameDomain + '/PublicImage/CertificateActive.png'" onerror="this.src='/PublicImage/CertificateActiveDisabled.png';" style="border:none;width:157px;height:30px;position:relative;top:15px;left:5px;" />
                                <div v-if="cust.CustomCNameDomain !=='' && cust_RESET.CustomCNameDomain!==cust.CustomCNameDomain && customDomainIsValid">
                                    <label class="c-txt__label">The following entries must exist in your DNS prior to changing the custom domain:</label>  
                                      <div class="DNS-container u-br-lg">
                                        <div class="DNS-container-row--head">Name</div>
                                        <div class="DNS-container-row--head">Type</div>
                                        <div class="DNS-container-row--head">Value</div>
                                        <div class="DNS-container-row--square">{{cust.CustomCNameDomain}}</div>
                                        <div class="DNS-container-row--square">CNAME</div>
                                        <div class="DNS-container-row--square"><%= klickzen.Config.KlickZenCNAMERoot %></div>
                                        <div class="DNS-container-row--square"><%= klickzen.Config.DNS_ValidateValueTXTRecord %>.{{customDomainTLD}}</div>
                                        <div class="DNS-container-row--square">TXT</div>
                                        <div class="DNS-container-row--square">"{{cust.DNS_ValidateValue}}"</div>
                                      </div>
                                </div>
                            </div>
                            <!-- need option here to request SSL -->

                            <div :class="'c-txt' + ((cust.DefaultPostActionURL==='' || cust.DefaultPostActionURL.isValidURL()) ? '' : ' c-txt_err')">
                                <label class="c-txt__label">Default Post-Action URL</label>
                                <small class="c-txt__hint u-fs-sm">
                                    This is the default URL of a web page that the user is redirected to after the button action is completed; 
                                    if left blank, the user will be sent to your <a href="#" @click="doShowSection('landingPage')">default landing page</a>; this value may be 
                                    overridden within a particular button's settings
                                </small>
                                <input type="text" class="c-txt__input u-2/3" v-model="cust.DefaultPostActionURL" maxlength="255" placeholder="https://www.YourCompany.com/LandingPage" />
                            </div>
                            <div class="bottom-button-padding">
                                <button class="c-btn c-btn--primary c-btn--danger" @click="cancelCustomerData" :disabled="viewSaving || viewGoodSave || viewBadSave">{{dataUnchanged ? "Close" : "Cancel"}}</button>
                                <button v-on:click="saveCustomerData" :disabled="!validSettings || dataUnchanged" class="c-btn c-btn--primary">Update</button>
                            </div>
                        </div>
                    </div>

                











                    <!-- HELP -->
                    <div v-cloak v-if="showSection=='help'" class="popSection">
                        <h2>{{appName}} Help</h2>
                        <div>
                            <p>
                                Klick-Zen allows you to quickly create functional Zendesk
                                action buttons that, when clicked by one of your end users,
                                takes an action on their ticket - such as adding a tag or setting
                                the value of a custom field.
                            </p>
                            <p>
                                These buttons can be automatically inserted into emails
                                that are sent to your end users via a trigger, or they may
                                be added manually by a Zendesk agent while creating a response
                                to a ticket.
                            </p>
                            <ol class="list-round">
                                <li>
                                    <h5>Create Buttons</h5>
                                    Use the button creator accessible from the <a href="#" @click="doShowSection('listButtons')">KlickButtons</a>
                                    section to add a new button from scratch. 
                                    <template v-cloak v-if="thisExecutionMode!==V_LITE">
                                    You may also click on one of the below buttons
                                    to use it as a template to get started:
                                    <div>
                                        <span v-for="but in genericButtonTemplates" style="margin-right:10px;">
                                            <button @click="startButtonCreate(but)" type="button" class="c-btn c-btn--sm" :style="'border:1px solid ' + but.BorderColor + ';background-color:' + but.BackgroundColor + ';color:' + but.TextColor">{{but.Name}}</button>
                                        </span>
                                    </div>
                                    </template>
                                </li>
                                <li>
                                    <h5>Add Buttons to Email Template</h5>
                                    When <a href="https://support.zendesk.com/hc/en-us/articles/203662106-Streamlining-workflow-with-ticket-updates-and-triggers" target="_zendeskhelp">creating a Zendesk trigger with an email response</a>,
                                    you may copy and paste the HTML for a KlickButton into a custom email template that
                                    is sent when one of your custom triggers is activated. The HTML for your
                                    KlickButton is available next to each listed button in the <a href="#" @click="doShowSection('listButtons')">KlickButtons</a>
                                    section.
                                </li>
                                <li>
                                    <h5>Insert Button in Ticket Editor</h5>
                                    When viewing a Zendesk ticket, your Zendesk agents can insert a KlickButton
                                    directly into a response by using the ticket editor button:
                                    <div><img src="img/TicketEditorSnap.png" alt="ticket editor button" /></div>
                                </li>
                            </ol>
                        </div>
                    </div>







                    <!-- info pop-under -->
                    <template v-cloak v-if="showSection!=='authorize'">
                        <div v-cloak v-if="thisExecutionMode===V_LITE" class="c-tooltip nag">
                            <span v-cloak v-if="cust.HasUsedTrial">
                                Your trial of {{appName}} has expired.
                            </span>
                            <span v-cloak v-else>
                                This version of {{appName}} is limited. 
                            </span>
                            The <a :href="FullVersionURL" target="_market">full version</a> offers additional features and no limitations.
                            <template v-if="!hasUsedTrialVersion && userIsAdmin">
                                <br /><a href="#" @click="showSection='trial'" style="color:#f3f357;">Click here to try out the full version free for 14 days!</a>
                            </template>
                        </div>
                        <div v-cloak v-if="thisExecutionMode===V_TRIALFULL" class="c-tooltip nag nag-<%=TrialDaysRemaining.ToString%>">
                            You have <b><%=TrialDaysRemaining.ToString%></b> days left in your trial;
                            your settings remain in place when you switch to the <a :href="FullVersionURL" target="_market">full version of {{appName}}</a>.
                        </div>
                    </template>






                    <!-- ### TOASTER ### -->
                    <transition name="fade">
                        <div v-cloak v-if="viewSaving && showSection!='main'" class="c-callout c-callout__float c-callout--dialog c-callout--warning">
                            <strong class="c-callout__title">
                                Updating...
                                <div class="loader" style="display:inline-block;margin-left:20px;"></div>
                            </strong>
                        </div>
                        <div v-cloak v-if="viewGoodSave && showSection!='main'" class="c-callout c-callout__float c-callout--dialog c-callout--success">
                            <strong class="c-callout__title">Success!</strong>
                        </div>
                        <div v-cloak v-if="viewBadSave && showSection!='main'" class="c-callout c-callout__float c-callout--dialog c-callout--error" style="z-index:99;">
                            <strong class="c-callout__title">{{badSaveMessage}}</strong>
                        </div>
                    </transition>




            </div>
        </div>
    </body>
</html>