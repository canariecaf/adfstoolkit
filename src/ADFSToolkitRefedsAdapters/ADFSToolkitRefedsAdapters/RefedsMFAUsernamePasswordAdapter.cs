// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Specialized;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Web;
using System.Xml;
using Microsoft.IdentityServer.Web.Authentication.External;
using Claim = System.Security.Claims.Claim;

namespace ADFSTk
{
    public class RefedsMFAUsernamePasswordAdapter : IAuthenticationAdapter
    {
        protected IAdapterPresentationForm CreateAdapterPresentation(string username)
        {
            return new UsernamePasswordPresentation(username);
        }

        protected IAdapterPresentationForm CreateAdapterPresentationOnError(string username, ExternalAuthenticationException ex)
        {
            return new UsernamePasswordPresentation(username, ex);
        }

        #region IAuthenticationAdapter Members

        public IAuthenticationAdapterMetadata Metadata => new RefedsMFAUsernamePasswordMetadata();

        public IAdapterPresentation BeginAuthentication(Claim identityClaim, HttpListenerRequest request, IAuthenticationContext authContext)
        {
            EventLog.WriteEntry("Freja eID", "Enter begin Authentication in FrejaAdapter", EventLogEntryType.Information, 335);
            
            foreach (var ss in authContext.Data.Keys)
            {
                EventLog.WriteEntry("Freja eID", "authcontext (" + ss + "): " + authContext.Data[ss], EventLogEntryType.Information, 335);
            }
            //request.Headers

            StreamReader reader = new StreamReader(request.InputStream);
            string text = reader.ReadToEnd();
            EventLog.WriteEntry("Freja eID", "InputStream: " + text, EventLogEntryType.Information, 335);
            foreach (var h in request.Headers.Keys)
            {
                EventLog.WriteEntry("Freja eID", "Header (" + h.ToString() + "): " + request.Headers[h.ToString()], EventLogEntryType.Information, 335);
            }

            if (null == identityClaim) throw new ArgumentNullException(nameof(identityClaim));

            if (null == authContext) throw new ArgumentNullException(nameof(authContext));

            if (String.IsNullOrEmpty(identityClaim.Value))
            {
                throw new InvalidDataException(ResourceHandler.GetResource(Constants.ResourceNames.ErrorNoUserIdentity, authContext.Lcid));
            }

            // save the current user ID in the encrypted blob.
            authContext.Data.Add(Constants.AuthContextKeys.Identity, identityClaim.Value);

            return CreateAdapterPresentation(identityClaim.Value);
        }

        public bool IsAvailableForUser(Claim identityClaim, IAuthenticationContext context)
        {
            return true;
        }

        public IAdapterPresentation OnError(HttpListenerRequest request, ExternalAuthenticationException ex)
        {
            if (ex == null)
            {
                throw new ArgumentNullException(nameof(ex));
            }

            return CreateAdapterPresentationOnError(String.Empty,ex);
        }

        public void OnAuthenticationPipelineLoad(IAuthenticationMethodConfigData configData)
        {
        }

        public void OnAuthenticationPipelineUnload()
        {
        }

        public IAdapterPresentation TryEndAuthentication(IAuthenticationContext authContext, IProofData proofData, HttpListenerRequest request, out Claim[] outgoingClaims)
        {
            if (null == authContext)
            {
                throw new ArgumentNullException(nameof(authContext));
            }

            outgoingClaims = new Claim[0];

            if (proofData?.Properties == null || !proofData.Properties.ContainsKey(Constants.PropertyNames.Password))
            {
                throw new ExternalAuthenticationException(ResourceHandler.GetResource(Constants.ResourceNames.ErrorNoAnswerProvided, authContext.Lcid), authContext);
            }

            if (!authContext.Data.ContainsKey(Constants.AuthContextKeys.Identity))
            {
                Trace.TraceError(string.Format("TryEndAuthentication Context does not contains userID."));
                throw new ArgumentOutOfRangeException(Constants.AuthContextKeys.Identity);
            }
            
            if (!authContext.Data.ContainsKey(Constants.AuthContextKeys.Identity))
            {
                throw new ArgumentNullException(Constants.AuthContextKeys.Identity);
            }
            
            string username = (string)authContext.Data[Constants.AuthContextKeys.Identity];
            string password = (string)proofData.Properties[Constants.PropertyNames.Password];

            try
            {
                if (PasswordValidator.Validate(username, password))
                {
                    //Get AuthNContextClassRef
                    var ctxClassToReturn = GetAuthNContextClass(request.Headers);
                    EventLog.WriteEntry("Freja eID", "authcontextclassref from authadapter: " + ctxClassToReturn , EventLogEntryType.Information, 335);
                    outgoingClaims = new Claim[]
                    {
                        new Claim(Constants.AuthenticationMethodClaimType, ctxClassToReturn)
                    };

                    // null == authentication succeeded.
                    return null;

                }
                else
                {
                    return CreateAdapterPresentationOnError(username, new UsernamePasswordValidationException("Authentication failed", authContext));
                }
            }
            catch (Exception ex)
            {
                throw new UsernamePasswordValidationException(string.Format("UsernamePasswordSecondFactor password validation failed due to exception {0} failed to validate password {0}", ex), ex, authContext);
            }
        }
        #endregion

        #region helpers
        private string GetAuthNContextClass(NameValueCollection headers)
        {
            string ctxClass = Constants.PasswordProtected;
            if (headers.AllKeys.Contains("Referer"))
            {
                var referer = headers.Get("Referer");
                var urlDecoded = new Uri(referer);
                var samlRequest = HttpUtility.ParseQueryString(urlDecoded.Query).Get("SAMLRequest");
                using (var memStream = new MemoryStream(Convert.FromBase64String(samlRequest)))
                {
                    using (var deflateStream = new DeflateStream(memStream, CompressionMode.Decompress))
                    {
                        string inflated = new StreamReader(deflateStream, System.Text.Encoding.UTF8).ReadToEnd();
                        XmlDocument xmlDoc = new XmlDocument();
                        xmlDoc.LoadXml(@inflated);
                        XmlNodeList nl = xmlDoc.DocumentElement.GetElementsByTagName("samlp:RequestedAuthnContext");
                        if (nl.Count > 0)
                        {
                            if (!string.IsNullOrEmpty(nl.Item(0).InnerText))
                            {
                                if (Constants.authNContextClasses.Contains(nl.Item(0).InnerText))
                                {
                                    ctxClass = Constants.authNContextClasses.Where(c => c.Equals(nl.Item(0).InnerText)).First();
                                }
                            }
                        }
                        xmlDoc = null;
                    }
                }
            }

            return ctxClass;

        }
        #endregion
    }
}
