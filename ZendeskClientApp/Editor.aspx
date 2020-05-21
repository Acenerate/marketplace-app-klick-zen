<%@ Page Language="VB" %>
<!DOCTYPE html>
<script runat="server">
    Dim custObj As String = "{}"
    Dim custButtons As String = "[]"
    Dim PreCheckAuth As String = "true"
    Dim customer_subdomain As String = String.Empty
    Dim IsTrialVersion As String = "false"
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


    ' TO-DO!!!
    ' have "defaults" for new buttons, so customer can maintain consistent look n feel







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
                    ExistingCustomer.SetAppPlan()
                End If

                'KlickZen.PublicFunctions.Logging.Log("Success authorizing " & customer_subdomain, KlickZen.PublicFunctions.Logging.LogType.INFORMATION)


                ' also, only show review reminder occasionally
                Select Case Today.Date.Day
                    Case 2, 10, 18, 26
                    Case Else
                        showReviewReminder = "false"
                End Select

                custObj = Newtonsoft.Json.JsonConvert.SerializeObject(ExistingCustomer)
                custButtons = Newtonsoft.Json.JsonConvert.SerializeObject(ExistingCustomer.ActionButtons)

                If ExistingCustomer.AppExecutionMode = KlickZen.KlickZenCustomer.AppExecutionModes.TRIALFULL Then
                    IsTrialVersion = "true"
                End If

                hasUsedTrial = ExistingCustomer.HasUsedTrial.ToString.ToLower
                TrialDaysRemaining = ExistingCustomer.TrialDaysRemaining.ToString

            End If

        End If

        custObj = Convert.ToBase64String(System.Text.ASCIIEncoding.ASCII.GetBytes(custObj))

    End Sub


</script>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Klick-Zen</title>
        <script src="https://static.zdassets.com/zendesk_app_framework_sdk/2.0/zaf_sdk.min.js"></script>
        <script>
            function initVars() {
                return {
                    FreeVersionLimit: <%=KlickZen.Config.FreeVersionLimit%>,
                    custObj: oXXil("<%=custObj%>"),
                    custButtons: Object.freeze(<%=custButtons%>),
                    appId: <%=KlickZen.Config.App_ID_Paid%>,
                    useageA: "<%=KlickZen.Config.App_ID_Paid%>",
                    useageB: "<%=KlickZen.Config.App_ID_Paid_local%>",
                    hasUsedTrial: <%=hasUsedTrial%>,
                    PreCheckAuth: <%=PreCheckAuth%>,
                    JwtToken: "<%=JwtToken%>"
                }
            }
        </script>

        <script defer src="https://cdn.jsdelivr.net/npm/vue@2.6.11/dist/vue.min.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/axios@0.18.0/dist/axios.min.js"></script>
        <script defer src="js/min/functions.<%=KlickZen.Config.CurrentAppVersion%>.js"></script>
        <script defer src="js/min/klick-zen-editor.<%=KlickZen.Config.CurrentAppVersion%>.js"></script>
        
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/combine/npm/@zendeskgarden/css-bedrock@7.0.8/dist/index.min.css,npm/@zendeskgarden/css-buttons@6.1.0/dist/index.min.css,npm/@zendeskgarden/css-forms@6.1.1/dist/index.min.css,npm/@zendeskgarden/css-utilities@3.1.1/dist/index.min.css,npm/@zendeskgarden/css-callouts@3.1.1/dist/index.min.css,npm/@zendeskgarden/css-tags@4.1.2/dist/index.min.css,npm/@zendeskgarden/css-tags@4.1.2/dist/index.min.css">
        <link rel="stylesheet" href="css/klick-zen.min.<%=KlickZen.Config.CurrentAppVersion%>.css">
        
        <style>
            body{
                background-color: #efefef;
            }
            .insert-button-container{
                margin: 0;
                padding: 0;
                display: flex;
            }
            .insert-button-container-child{
                padding: 2px 3px;
                margin:0;
                cursor: pointer;
            }
            .insert-button-container-child:hover{
                transition: transform 0.5s;
                transform: translate(0, -1px);
            }
        </style>

    </head>
    <body>
        <div id="app">
            <div v-cloak v-if="cust.AllowTicketEditor" class="insert-button-container">
                <div v-for="butt in enabledButtons" @click="insertButton(butt)" class="insert-button-container-child">
                    <img :src="'/ext/src/' + butt.AccessGuid + '/00000-0000'" />
                </div>
                <div v-cloak v-if="!enabledButtons.length" class="editor-message">
                    No KlickButtons defined
                </div>
            </div>
            <div v-cloak v-else class="editor-message">
                    Admin has disabled Klickbuttons
            </div>
        </div>
    </body>
</html>