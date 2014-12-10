<?xml version="1.0" encoding="UTF-8"?>
<!--
 | Copyright (c) 2012 Symplectic Limited. All rights reserved.
 | This Source Code Form is subject to the terms of the Mozilla Public
 | License, v. 2.0. If a copy of the MPL was not distributed with this
 | file, You can obtain one at http://mozilla.org/MPL/2.0/.
 -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:bibo="http://purl.org/ontology/bibo/"
                xmlns:vivo="http://vivoweb.org/ontology/core#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:score="http://vivoweb.org/ontology/score#"
                xmlns:ufVivo="http://vivo.ufl.edu/ontology/vivo-ufl/"
                xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#"
                xmlns:api="http://www.symplectic.co.uk/publications/api"
                xmlns:symp="http://www.symplectic.co.uk/vivo/"
                xmlns:svfn="http://www.symplectic.co.uk/vivo/namespaces/functions"
                xmlns:config="http://www.symplectic.co.uk/vivo/namespaces/config"
                exclude-result-prefixes="rdf rdfs bibo vivo foaf score ufVivo vitro api symp svfn config xs"
        >

    <!--
        Template for handling relationships between users and professional activities.
    -->

    <!-- Import XSLT files that are used -->
    <xsl:import href="elements-to-vivo-activity.xsl" />
    <xsl:import href="elements-to-vivo-utils.xsl" />

    <!-- Match relationship of type activity-to-user association -->
    <xsl:template match="api:relationship[@type='activity-user-association']">
        <!--
            Apply templates on the activity object, in "processRelationship" mode
            This allows the activity to apply it's statements to the user object, if necessary
        -->
        <xsl:apply-templates select="api:related/api:object[@category='activity']" mode="processRelationship"> <!-- api:related[@direction='from']/api:object mode="professionalActivityRelationship" -->
            <!-- Supply the URI of the user object that is related as a parameter -->
            <xsl:with-param name="userURI" select="svfn:userURI(api:related/api:object[@category='user'])" />
        </xsl:apply-templates>
    </xsl:template>
</xsl:stylesheet>
