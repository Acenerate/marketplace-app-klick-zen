var startTour;(function(){var a=["\x4E\x65\x78\x74\x20\x3E","\x3C\x20\x42\x61\x63\x6B","\x45\x78\x69\x74","\x23\x72\x69\x62\x62\x6F\x6E\x5F\x74\x6F\x75\x72\x5F\x73\x74\x61\x72\x74","\x57\x65\x6C\x63\x6F\x6D\x65\x20\x74\x6F\x20\x3C\x62\x3E","\x20\x66\x6F\x72\x20","\x3C\x2F\x62\x3E\x21\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x50\x6C\x65\x61\x73\x65\x20\x61\x6C\x6C\x6F\x77\x20\x75\x73\x20\x61\x20\x6D\x6F\x6D\x65\x6E\x74\x20\x74\x6F\x20\x73\x68\x6F\x77\x20\x79\x6F\x75\x20\x61\x72\x6F\x75\x6E\x64\x2E\x2E\x2E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E","\x20\x61\x6C\x6C\x6F\x77\x73\x20\x79\x6F\x75\x20\x74\x6F\x20\x61\x73\x73\x6F\x63\x69\x61\x74\x65\x20\x79\x6F\x75\x72\x20","\x20","\x20\x63\x6F\x6D\x6D\x69\x74\x73\x2F\x63\x68\x65\x63\x6B\x69\x6E\x73\x20\x77\x69\x74\x68\x20\x5A\x65\x6E\x64\x65\x73\x6B\x20\x74\x69\x63\x6B\x65\x74\x73\x2E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x59\x6F\x75\x20\x63\x61\x6E\x20\x61\x6C\x73\x6F\x20\x63\x72\x65\x61\x74\x65\x20\x6E\x65\x77\x20\x5A\x65\x6E\x64\x65\x73\x6B\x2D\x61\x73\x73\x6F\x63\x69\x61\x74\x65\x64\x20","\x73\x2C\x20\x61\x73\x20\x77\x65\x6C\x6C\x20\x61\x73\x20\x6C\x69\x6E\x6B\x20\x65\x78\x69\x73\x74\x69\x6E\x67\x20","\x73\x2E","\x23\x72\x69\x62\x62\x6F\x6E\x5F\x73\x65\x74\x74\x69\x6E\x67\x73","\x3C\x62\x3E\x53\x65\x74\x74\x69\x6E\x67\x73\x3C\x2F\x62\x3E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x54\x6F\x20\x67\x65\x74\x20\x73\x74\x61\x72\x74\x65\x64\x2C\x20\x66\x69\x72\x73\x74\x20\x65\x78\x70\x6C\x6F\x72\x65\x20\x74\x68\x65\x20\x73\x65\x74\x74\x69\x6E\x67\x73\x20\x6F\x70\x74\x69\x6F\x6E\x73\x20\x74\x68\x61\x74\x20\x79\x6F\x75\x20\x68\x61\x76\x65\x20\x61\x76\x61\x69\x6C\x61\x62\x6C\x65\x2C\x20\x73\x75\x63\x68\x20\x61\x73\x20\x74\x68\x65\x20\x74\x72\x69\x67\x67\x65\x72\x73\x20\x66\x6F\x72\x20\x5A\x65\x6E\x64\x65\x73\x6B\x20\x74\x69\x63\x6B\x65\x74\x20\x63\x6F\x6D\x6D\x65\x6E\x74\x73\x2C\x20\x61\x73\x20\x77\x65\x6C\x6C\x20\x61\x73\x20\x77\x68\x61\x74\x20\x66\x65\x61\x74\x75\x72\x65\x73\x20\x77\x69\x6C\x6C\x20\x62\x65\x20\x61\x76\x61\x69\x6C\x61\x62\x6C\x65\x20\x74\x6F\x20\x79\x6F\x75\x72\x20\x5A\x65\x6E\x64\x65\x73\x6B\x20\x61\x67\x65\x6E\x74\x73\x2E","\x20\x3C\x62\x3E\x3C\x75\x3E\x49\x74\x20\x69\x73\x20\x61\x6C\x73\x6F\x20\x69\x6D\x70\x6F\x72\x74\x61\x6E\x74\x20\x68\x65\x72\x65\x20\x74\x6F\x20\x65\x6E\x73\x75\x72\x65\x20\x74\x68\x61\x74\x20\x79\x6F\x75\x72\x20","\x20\x4F\x72\x67\x61\x6E\x69\x7A\x61\x74\x69\x6F\x6E\x20\x4E\x61\x6D\x65\x20\x69\x73\x20\x6C\x69\x73\x74\x65\x64\x20\x63\x6F\x72\x72\x65\x63\x74\x6C\x79\x2E\x3C\x2F\x75\x3E\x3C\x2F\x62\x3E","","\x23\x72\x69\x62\x62\x6F\x6E\x5F\x77\x65\x62\x68\x6F\x6F\x6B\x73","\x3C\x62\x3E\x57\x65\x62\x68\x6F\x6F\x6B\x73\x3C\x2F\x62\x3E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x4E\x65\x78\x74\x2C\x20\x62\x65\x20\x73\x75\x72\x65\x20\x74\x6F\x20\x63\x6C\x69\x63\x6B\x20\x68\x65\x72\x65\x20\x74\x6F\x20\x73\x65\x6C\x65\x63\x74\x20\x77\x68\x69\x63\x68\x20","\x28\x73\x29\x20\x79\x6F\x75\x20\x77\x69\x73\x68\x20\x74\x6F\x20\x6C\x69\x6E\x6B\x3B\x20\x3C\x62\x3E\x3C\x75\x3E\x74\x68\x69\x73\x20\x73\x74\x65\x70\x20\x69\x73\x20\x65\x73\x73\x65\x6E\x74\x69\x61\x6C\x3C\x2F\x75\x3E\x3C\x2F\x62\x3E\x2C\x20\x61\x73\x20\x69\x74\x20\x61\x64\x64\x73\x20\x74\x68\x65\x20\x6E\x65\x63\x65\x73\x73\x61\x72\x79\x20\x77\x65\x62\x68\x6F\x6F\x6B\x73\x20\x74\x6F\x20\x74\x68\x65\x20","\x20\x73\x6F\x20\x74\x68\x61\x74\x20\x69\x74\x20\x63\x61\x6E\x20\x63\x6F\x6D\x6D\x75\x6E\x69\x63\x61\x74\x65\x20\x62\x61\x63\x6B\x20\x74\x6F\x20","\x2E","\x23\x72\x69\x62\x62\x6F\x6E\x5F\x63\x72\x65\x61\x74\x65","\x3C\x62\x20\x63\x6C\x61\x73\x73\x3D\x27\x63\x61\x70\x2D\x6D\x65\x27\x3E\x43\x72\x65\x61\x74\x65\x20\x4E\x65\x77\x20","\x3C\x2F\x62\x3E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x54\x68\x69\x73\x20\x66\x65\x61\x74\x75\x72\x65\x20\x77\x69\x6C\x6C\x20\x61\x6C\x6C\x6F\x77\x20\x79\x6F\x75\x20\x74\x6F\x20\x63\x72\x65\x61\x74\x65\x20\x61\x20\x6E\x65\x77\x20","\x20\x64\x69\x72\x65\x63\x74\x6C\x79\x20\x66\x72\x6F\x6D\x20\x74\x68\x69\x73\x20\x5A\x65\x6E\x64\x65\x73\x6B\x20\x74\x69\x63\x6B\x65\x74\x2C\x20\x77\x69\x74\x68\x20\x76\x61\x72\x69\x6F\x75\x73\x20\x6F\x70\x74\x69\x6F\x6E\x73\x20\x73\x75\x63\x68\x20\x61\x73\x20\x61\x73\x73\x69\x67\x6E\x69\x6E\x67\x20\x69\x74\x20\x74\x6F\x20\x73\x6F\x6D\x65\x6F\x6E\x65\x2C\x20\x61\x73\x20\x77\x65\x6C\x6C\x20\x61\x73\x20\x61\x64\x64\x69\x6E\x67\x20","\x23\x72\x69\x62\x62\x6F\x6E\x5F\x6C\x69\x6E\x6B","\x3C\x62\x20\x63\x6C\x61\x73\x73\x3D\x27\x63\x61\x70\x2D\x6D\x65\x27\x3E\x4C\x69\x6E\x6B\x20\x45\x78\x69\x73\x74\x69\x6E\x67\x20","\x3C\x2F\x62\x3E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x55\x73\x65\x20\x74\x68\x69\x73\x20\x62\x75\x74\x74\x6F\x6E\x20\x74\x6F\x20\x71\x75\x69\x63\x6B\x6C\x79\x20\x61\x6E\x64\x20\x65\x61\x73\x69\x6C\x79\x20\x6C\x69\x6E\x6B\x20\x61\x6E\x20\x65\x78\x69\x73\x74\x69\x6E\x67\x20","\x20\x74\x6F\x20\x74\x68\x69\x73\x20\x5A\x65\x6E\x64\x65\x73\x6B\x20\x74\x69\x63\x6B\x65\x74\x2E","\x23\x72\x69\x62\x62\x6F\x6E\x5F\x65\x64\x69\x74","\x3C\x62\x3E\x45\x64\x69\x74\x20\x4D\x6F\x64\x65\x3C\x2F\x62\x3E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x55\x73\x65\x20\x74\x68\x69\x73\x20\x66\x65\x61\x74\x75\x72\x65\x20\x74\x6F\x20\x72\x65\x6D\x6F\x76\x65\x20\x6C\x69\x6E\x6B\x73\x20\x74\x6F\x20","\x73\x20\x61\x6E\x64\x20\x63\x6F\x6D\x6D\x69\x74\x73\x20\x74\x68\x61\x74\x20\x79\x6F\x75\x20\x6E\x6F\x20\x6C\x6F\x6E\x67\x65\x72\x20\x77\x69\x73\x68\x20\x74\x6F\x20\x68\x61\x76\x65\x20\x61\x73\x73\x6F\x63\x69\x61\x74\x65\x64\x20\x77\x69\x74\x68\x20\x74\x68\x69\x73\x20\x5A\x65\x6E\x64\x65\x73\x6B\x20\x74\x69\x63\x6B\x65\x74\x2E","\x23\x72\x69\x62\x62\x6F\x6E\x5F\x68\x65\x6C\x70","\x3C\x62\x3E\x48\x65\x6C\x70\x3C\x2F\x62\x3E\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x49\x66\x20\x79\x6F\x75\x20\x61\x72\x65\x20\x69\x6E\x20\x6E\x65\x65\x64\x20\x6F\x66\x20\x68\x65\x6C\x70\x2C\x20\x74\x68\x65\x72\x65\x20\x69\x73\x20\x73\x6F\x6D\x65\x20\x61\x64\x64\x69\x74\x69\x6F\x6E\x61\x6C\x20\x69\x6E\x66\x6F\x72\x6D\x61\x74\x69\x6F\x6E\x20\x68\x65\x72\x65\x20\x74\x68\x61\x74\x20\x63\x61\x6E\x20\x70\x6F\x69\x6E\x74\x20\x79\x6F\x75\x20\x69\x6E\x20\x74\x68\x65\x20\x72\x69\x67\x68\x74\x20\x64\x69\x72\x65\x63\x74\x69\x6F\x6E\x2E","\x54\x68\x61\x74\x27\x73\x20\x61\x6C\x6C\x21\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x49\x66\x20\x79\x6F\x75\x20\x61\x72\x65\x20\x69\x6E\x20\x6E\x65\x65\x64\x20\x6F\x66\x20\x66\x75\x72\x74\x68\x65\x72\x20\x61\x73\x73\x69\x73\x74\x61\x6E\x63\x65\x2C\x20\x64\x6F\x6E\x27\x74\x20\x68\x65\x73\x69\x74\x61\x74\x65\x20\x74\x6F\x20\x63\x6F\x6E\x74\x61\x63\x74\x20\x75\x73\x20\x61\x20\x3C\x61\x20\x68\x72\x65\x66\x3D\x27\x6D\x61\x69\x6C\x74\x6F\x3A\x73\x75\x70\x70\x6F\x72\x74\x40\x67\x69\x74\x2D\x7A\x65\x6E\x2E\x63\x6F\x6D\x27\x3E\x73\x75\x70\x70\x6F\x72\x74\x40\x67\x69\x74\x2D\x7A\x65\x6E\x2E\x63\x6F\x6D\x3C\x2F\x61\x3E\x2E\x20\x46\x75\x72\x74\x68\x65\x72\x20\x69\x6E\x73\x74\x61\x6C\x6C\x61\x74\x69\x6F\x6E\x20\x69\x6E\x73\x74\x72\x75\x63\x74\x69\x6F\x6E\x73\x20\x61\x72\x65\x20\x61\x76\x61\x69\x6C\x61\x62\x6C\x65\x20\x61\x74\x20\x3C\x61\x20\x68\x72\x65\x66\x3D\x27","\x27\x20\x74\x61\x72\x67\x65\x74\x3D\x27\x67\x68\x5F\x68\x65\x6C\x70\x27\x3E","\x3C\x2F\x61\x3E\x2E\x20\x3C\x62\x72\x2F\x3E\x3C\x62\x72\x2F\x3E\x3C\x62\x3E\x54\x68\x61\x6E\x6B\x20\x79\x6F\x75\x20\x66\x6F\x72\x20\x75\x73\x69\x6E\x67\x20","\x21\x3C\x2F\x62\x3E"];function b(){var b=introJs();b.setOptions({nextLabel:a[0],prevLabel:a[1],skipLabel:a[2],overlayOpacity:0.2,showBullets:true,exitOnOverlayClick:false,showStepNumbers:false,steps:[{element:a[3],intro:a[4]+ vm.appName+ a[5]+ Provider.Name+ a[6]},{element:a[3],intro:vm.appName+ a[7]+ Provider.Name+ a[8]+ Provider.ReposName+ a[9]+ Provider.IssuesName+ a[10]+ Provider.IssuesName+ a[11]},{element:a[12],intro:a[13]+ (Provider.SpecifyOrganization?a[14]+ Provider.Name+ a[15]:a[16])},{element:a[17],intro:a[18]+ Provider.ReposName+ a[19]+ Provider.ReposName+ a[20]+ vm.appName+ a[21]},{element:a[22],intro:a[23]+ Provider.IssuesName+ a[24]+ Provider.IssuesName+ a[25]+ Provider.LabelsName+ a[11]},{element:a[26],intro:a[27]+ Provider.IssuesName+ a[28]+ Provider.IssuesName+ a[29]},{element:a[30],intro:a[31]+ Provider.IssuesName+ a[32]},{element:a[33],intro:a[34]},{element:a[3],intro:a[35]+ Provider.InstallationInstructions+ a[36]+ Provider.InstallationInstructions+ a[37]+ vm.appName+ a[38]}]});b.start()}startTour= b;})()