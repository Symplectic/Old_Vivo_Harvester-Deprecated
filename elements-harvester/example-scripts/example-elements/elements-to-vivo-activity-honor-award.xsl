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

    <!-- Import general config / utils XSLT -->
    <xsl:import href="elements-to-vivo-config.xsl" />
    <xsl:import href="elements-to-vivo-utils.xsl" />

    <!--
        Honor Award Professional Activity
        =================================
        This professional activity is specifying 'awards' granted to a particular user.

        Although it is defined in Elements as an authority controlled value, a new 'object' with a copy of the label is created for each user.
    -->
    <xsl:template match="api:object[@category='activity' and @type='c-honor-award']">
        <!--
            Create a distinct object (URI) for each award.
            As the award may contain an award date (i.e. the date it was awarded to an individual),
            then the entire object with date must be distinct to each individual, even if it is the same award.
        -->
        <!--<xsl:variable name="honorAwardURI" select="svfn:objectURI(.)" />-->

        <xsl:variable name="honorAwardName" select="api:records/api:record/api:native/api:field[@name='c-certification-honor-award-name']/api:text"/>



        <!--
            If we were associating multiple individuals to the same award, we would use the following URI generator
            - which would use a URI-safe version of the label to create consistent URLs for the same award.
        -->
            <xsl:variable name="honorAwardURI" select="concat($baseURI, 'award-', svfn:stringToURI($honorAwardName))" />

        <!-- Output the honor award -->
        <xsl:call-template name="render_rdf_object">
            <xsl:with-param name="objectURI" select="$honorAwardURI" />
            <xsl:with-param name="rdfNodes">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Award"/>
                <rdfs:label><xsl:value-of select="$honorAwardName" /></rdfs:label>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <!--
        Honor Award Relationship
        ========================
        The honor award is created as an object, so we need to create a relationship between it and the user.
    -->
    <xsl:template match="api:object[@category='activity' and @type='c-19']" mode="processRelationship">
        <xsl:param name="userURI" />

        <!--
            Create a distinct object (URI) for each award.
            As the award may contain an award date (i.e. the date it was awarded to an individual),
            then the entire object with date must be distinct to each individual, even if it is the same award.
        -->
        <xsl:variable name="honorAwardURI" select="svfn:objectURI(.)" />

        <xsl:text>Bitch, pretty please.</xsl:text>

        <!--
            Add relationship information to the user object
        -->
        <xsl:call-template name="render_rdf_object">
            <xsl:with-param name="objectURI" select="$userURI" />
            <xsl:with-param name="rdfNodes">
                <vivo:awardOrHonor rdf:resource="{$honorAwardURI}"/>
            </xsl:with-param>
        </xsl:call-template>

        <!--
            Add relationship information to the honor award object
        -->
        <xsl:call-template name="render_rdf_object">
            <xsl:with-param name="objectURI" select="$honorAwardURI" />
            <xsl:with-param name="rdfNodes">
                <vivo:awardOrHonorFor rdf:resource="{$userURI}"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
