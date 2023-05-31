// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace ADFSTk
{
    internal static class Constants
    {

        public const string RefedsMFA = "https://refeds.org/profile/mfa";
        public const string RefedsSFA = "https://refeds.org/profile/sfa";
        public const string Password1 = "urn:oasis:names:tc:SAML:1.0:am:password";
        public const string Password2 = "urn:oasis:names:tc:SAML:2.0:ac:classes:Password";
        public const string PasswordProtected = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport";
        public const string Password3 = "http://schemas.microsoft.com/ws/2008/06/identity/authenticationmethod/password";
        public const string ADFSTkPasswordProtected = "urn:adfstk:PasswordProtectedTransport";
        /*
          <d5p1:string>urn:oasis:names:tc:SAML:1.0:am:password</d5p1:string>
					<d5p1:string>urn:oasis:names:tc:SAML:2.0:ac:classes:Password</d5p1:string>
					<d5p1:string>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</d5p1:string>
					<d5p1:string>http://schemas.microsoft.com/ws/2008/06/identity/authenticationmethod/password</d5p1:string>
        */
        public static string[] handledAuthNContextClasses =
        {
            RefedsMFA,
            RefedsSFA,
            ADFSTkPasswordProtected,
            PasswordProtected
        };

        public static string[] authNContextClasses =
        {
            RefedsMFA,
            RefedsSFA,
            Password1,
            Password2,
            Password3,
            PasswordProtected,
            ADFSTkPasswordProtected
        };


        public const string AuthenticationMethodClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationmethod";
        public const string WindowsAccountNameClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname";
        public const string UpnClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn";

        public static class AuthContextKeys
        {
            public const string SessionId = "sessionid";
            public const string Identity = "id";
        }

        public static class DynamicContentLabels
        {
            public const string markerUserName = "%LoginPageUserName%";
            public const string markerOverallError = "%PageErrorOverall%";
            public const string markerActionUrl = "%PageActionUrl%";
            public const string markerPageIntroductionTitle = "%PageIntroductionTitle%";
            public const string markerPageIntroductionText = "%PageIntroductionText%";
            public const string markerPageTitle = "%PageTitle%";
            public const string markerSubmitButton = "%PageSubmitButtonLabel%";
            public const string markerChoiceSuccess = "%ChoiceSuccess%";
            public const string markerChoiceFail = "%ChoiceFail%";
            public const string markerUserChoice = "%UserChoice%";
            public const string markerLoginPageUsername = "%Username%";
            public const string markerLoginPagePasswordLabel = "%LoginPagePasswordLabel%";

        }

        public static class ResourceNames
        {
            public const string AdminFriendlyNameMFA = "Forms Authentication (RefedsMFA)";
            public const string AdminFriendlyNameSFA = "Forms Authentication (RefedsSFA)";
            public const string Description = "Description";
            public const string FriendlyName = "FriendlyName";//saknas i resources
            public const string PageIntroductionTitle = "PageIntroductionTitle";
            public const string PageIntroductionText = "PageIntroductionText";
            public const string AuthPageTemplate = "LoginPasswordHtml";
            public const string PageTitle = "PageTitle";
            public const string SubmitButtonLabel = "SubmitButtonLabel";
            public const string AuthenticationFailed = "AuthenticationFailed";
            public const string ErrorInvalidSessionId = "ErrorInvalidSessionId";
            public const string ErrorInvalidContext = "ErrorInvalidContext";
            public const string ErrorNoUserIdentity = "ErrorNoUserIdentity";
            public const string ErrorNoAnswerProvided = "ErrorNoAnswerProvided";
            public const string ErrorFailSelected = "ErrorFailSelected";
            public const string ChoiceSuccess = "ChoiceSuccess";
            public const string ChoiceFail = "ChoiceFail";
            public const string UserChoice = "UserChoice";
            public const string FailedLogin = "FailedLogin";
        }

        public static class PropertyNames
        {
            public const string UserSelection = "UserSelection";
            public const string AuthenticationMethod = "AuthMethod";
            public const string Password = "PasswordInput";
            public const string Username = "Username";
        }

        public static class Lcid
        {
            public const int En = 0x9;   
            public const int Sv = 0x1D;      
        }
    }
}
