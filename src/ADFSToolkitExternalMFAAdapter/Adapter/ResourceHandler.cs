﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Globalization;
using ADFSTK.ExternalMFA.Resources;

namespace ADFSTK.ExternalMFA
{
    internal static class ResourceHandler
    {
        public static string GetResource(string resourceName, int lcid)
        {
            if (String.IsNullOrEmpty(resourceName))
            {
                throw new ArgumentNullException("resourceName");
            }

            return StringResources.ResourceManager.GetString(resourceName, new CultureInfo(lcid));
        }

        public static string GetPresentationResource(string resourceName, int lcid)
        {
            if (String.IsNullOrEmpty(resourceName))
            {
                throw new ArgumentNullException("resourceName");
            }
            return PresentationResources.ResourceManager.GetString(resourceName, new CultureInfo(lcid));
        }
    }
}
