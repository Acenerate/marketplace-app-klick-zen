function startTour() {
    var intro = introJs();
    intro.setOptions({
        nextLabel: "Next >",
        prevLabel: "< Back",
        skipLabel: "Exit",
        overlayOpacity: 0.2,
        showBullets: true,
        exitOnOverlayClick: false,
        showStepNumbers: false,
        steps: [
            {
                element: "#ribbon_tour_start",
                intro: "Welcome to <b>" + vm.appName + " for " + Provider.Name + "</b>!<br/><br/>Please allow us a moment to show you around...<br/><br/>"            },
            {
                element: "#ribbon_tour_start",
                intro: vm.appName + " allows you to associate your " + Provider.Name + " " + Provider.ReposName + " commits/checkins with Zendesk tickets.<br/><br/>You can also create new Zendesk-associated " + Provider.IssuesName + "s, as well as link existing " + Provider.IssuesName + "s."
            },
            {
                element: '#ribbon_settings',
                intro: "<b>Settings</b><br/><br/>To get started, first explore the settings options that you have available, such as the triggers for Zendesk ticket comments, as well as what features will be available to your Zendesk agents." + (Provider.SpecifyOrganization ? " <b><u>It is also important here to ensure that your " + Provider.Name + " Organization Name is listed correctly.</u></b>" : "")
            },
            {
                element: "#ribbon_webhooks",
                intro: "<b>Webhooks</b><br/><br/>Next, be sure to click here to select which " + Provider.ReposName + "(s) you wish to link; <b><u>this step is essential</u></b>, as it adds the necessary webhooks to the " + Provider.ReposName + " so that it can communicate back to " + vm.appName + "."
            },
            {
                element: '#ribbon_create',
                intro: "<b class='cap-me'>Create New " + Provider.IssuesName + "</b><br/><br/>This feature will allow you to create a new " + Provider.IssuesName + " directly from this Zendesk ticket, with various options such as assigning it to someone, as well as adding " + Provider.LabelsName + "s."
            },
            {
                element: '#ribbon_link',
                intro: "<b class='cap-me'>Link Existing " + Provider.IssuesName + "</b><br/><br/>Use this button to quickly and easily link an existing " + Provider.IssuesName + " to this Zendesk ticket."
            },
            {
                element: '#ribbon_edit',
                intro: "<b>Edit Mode</b><br/><br/>Use this feature to remove links to " + Provider.IssuesName + "s and commits that you no longer wish to have associated with this Zendesk ticket."
            },
            {
                element: '#ribbon_help',
                intro: "<b>Help</b><br/><br/>If you are in need of help, there is some additional information here that can point you in the right direction."
            },
            {
                element: "#ribbon_tour_start",
                intro: "That's all!<br/><br/>If you are in need of further assistance, don't hesitate to contact us a <a href='mailto:support@git-zen.com'>support@git-zen.com</a>. Further installation instructions are available at <a href='" + Provider.InstallationInstructions + "' target='gh_help'>" + Provider.InstallationInstructions + "</a>. <br/><br/><b>Thank you for using " + vm.appName + "!</b>"
            }
        ]
    });

    intro.start();
}