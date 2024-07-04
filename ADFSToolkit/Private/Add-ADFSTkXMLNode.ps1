function Add-ADFSTkXMLNode {
    param (
        $Xml,
        $XPathParentNode,
        $Node
    )
    
    $configurationNode = Select-Xml -Xml $Xml -XPath $XPathParentNode
    $configurationNode.Node.AppendChild($Xml.ImportNode($Node, $true)) | Out-Null
}