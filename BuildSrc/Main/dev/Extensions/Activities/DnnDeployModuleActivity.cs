﻿using Build.Extensions.DotNetNuke;
using Microsoft.TeamFoundation.Build.Client;
using System.Activities;
using System.Globalization;
using System.IO;
using TfsBuildExtensions.Activities;

namespace Build.Extensions.Activities
{
    [BuildActivity(HostEnvironmentOption.All)]
    public class DnnDeployModuleActivity : BaseCodeActivity
    {
        [RequiredArgument]
        public InArgument<string> TargetDnnRootUrl { get; set; }

        [RequiredArgument]
        public InArgument<string> ModuleFilePath { get; set; }

        public InArgument<string> TargetDnnUserName { get; set; }

        public InArgument<string> TargetDnnPassword { get; set; }

        public InArgument<bool> DeleteModuleFirstIfFound { get; set; }

        protected override void InternalExecute()
        {
            var targetDnnRootUrl = TargetDnnRootUrl.Get(this.ActivityContext);
            var moduleFilePath = ModuleFilePath.Get(this.ActivityContext);

            var userName = TargetDnnUserName.Get(this.ActivityContext);
            var password = TargetDnnPassword.Get(this.ActivityContext);
            var deleteModuleFirstIfFound = DeleteModuleFirstIfFound.Get(this.ActivityContext);

            if (string.IsNullOrEmpty(targetDnnRootUrl)) { this.LogBuildError("TargetDnnRootUrl is required."); return; }
            if (string.IsNullOrEmpty(moduleFilePath)) { this.LogBuildError("ModuleFilePath is required."); return; }


            var client = new ModuleAdminClient(targetDnnRootUrl, userName, password);
            if (!client.IsDeployerInstalled())
            {
                this.LogBuildError(string.Format(CultureInfo.CurrentCulture, "Deployer Service not installed on '{0}'\nError Message: '{1}'", targetDnnRootUrl, client.LastResponse.ErrorMessage));
                return;
            }

            this.LogBuildMessage(string.Format("Installing '{0}' client to {1}", Path.GetFileName(moduleFilePath), targetDnnRootUrl), BuildMessageImportance.High);
            var success = client.ModuleInstall(deleteModuleFirstIfFound, moduleFilePath);
            if (success)
            { this.LogBuildMessage(string.Format("Package '{0}' installed successfully", Path.GetFileName(moduleFilePath)), BuildMessageImportance.High); }
            else
            { this.LogBuildError(string.Format("Error installing package '{0}' on '{1}'. ERROR: '{2}'", Path.GetFileName(moduleFilePath), targetDnnRootUrl, client.LastResponse.Content)); }
        }


    }
}
