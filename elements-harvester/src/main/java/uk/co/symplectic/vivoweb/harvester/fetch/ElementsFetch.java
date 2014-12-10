/*******************************************************************************
 * Copyright (c) 2012 Symplectic Ltd. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 ******************************************************************************/
package uk.co.symplectic.vivoweb.harvester.fetch;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.co.symplectic.elements.api.ElementsAPI;
import uk.co.symplectic.elements.api.ElementsAPIFeedObjectQuery;
import uk.co.symplectic.elements.api.ElementsAPIFeedRelationshipQuery;
import uk.co.symplectic.elements.api.ElementsObjectCategory;
import uk.co.symplectic.translate.TranslationService;
import uk.co.symplectic.vivoweb.harvester.store.ElementsObjectStore;
import uk.co.symplectic.vivoweb.harvester.store.ElementsRdfStore;
import uk.co.symplectic.vivoweb.harvester.store.ElementsStoreFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ElementsFetch {
    /**
     * SLF4J Logger
     */
    private static Logger log = LoggerFactory.getLogger(ElementsFetch.class);

    private String objectsToHarvest;
    private String groupsToHarvest;

    // Default of 25 is required by 4.6 API since we request full detail for objects
    private int objectsPerPage = 25;

    // Default of 100 for optimal performance
    private int relationshipsPerPage = 100;

    private final List<ElementsObjectObserver> objectObservers = new ArrayList<ElementsObjectObserver>();
    private final List<ElementsRelationshipObserver> relationshipObservers = new ArrayList<ElementsRelationshipObserver>();

    private ElementsAPI elementsAPI = null;

    public ElementsFetch(ElementsAPI api) {
        if (api == null) {
            throw new IllegalStateException();
        }

        this.elementsAPI = api;
    }

    public void addObjectObserver(ElementsObjectObserver newObserver) {
        objectObservers.add(newObserver);
    }

    public void addRelationshipObserver(ElementsRelationshipObserver newObserver) {
        relationshipObservers.add(newObserver);
    }

    public void setGroupsToHarvest(String groupsToHarvest) {
        this.groupsToHarvest = groupsToHarvest;
    }

    public void setObjectsToHarvest(String objectsToHarvest) {
        this.objectsToHarvest = objectsToHarvest;
    }

    public void setObjectsPerPage(int objectsPerPage) {
        this.objectsPerPage = objectsPerPage;
    }

    public void setRelationshipsPerPage(int relationshipsPerPage) {
        this.relationshipsPerPage = relationshipsPerPage;
    }

    /**
     * Executes the task
     * @throws IOException error processing search
     */
    public void execute() throws IOException {
        ElementsObjectStore objectStore = ElementsStoreFactory.getObjectStore();
        ElementsRdfStore rdfStore = ElementsStoreFactory.getRdfStore();

        ElementsAPIFeedObjectQuery feedQuery = new ElementsAPIFeedObjectQuery();

        // When retrieving objects, always get the full record
        feedQuery.setFullDetails(true);

        // Get N objects per request
        feedQuery.setPerPage(objectsPerPage);

        // Load all pages, not just one
        feedQuery.setProcessAllPages(true);

        if (!StringUtils.isEmpty(groupsToHarvest)) {
            feedQuery.setGroups(groupsToHarvest);
        }

        // objectsToHarvest is a comma delimited list of object categories that we wish to pull
        // As the API requires that we handle each category separately, we split the string and loop over the contents
        for (String category : objectsToHarvest.split("\\s*,\\s*")) {
            ElementsObjectCategory eoCategory = ElementsObjectCategory.valueOf(category);
            if (eoCategory != null) {
                feedQuery.setCategory(eoCategory);
                ElementsObjectHandler objectHandler = new ElementsObjectHandler(objectStore);

                for (ElementsObjectObserver objectObserver : objectObservers) {
                    objectHandler.addObserver(objectObserver);
                }

                elementsAPI.execute(feedQuery, objectHandler);
            }
        }

        ElementsAPIFeedRelationshipQuery relationshipFeedQuery = new ElementsAPIFeedRelationshipQuery();
        relationshipFeedQuery.setProcessAllPages(true);
        relationshipFeedQuery.setPerPage(relationshipsPerPage);
        ElementsObjectsInRelationships objectsInRelationships = new ElementsObjectsInRelationships();

        ElementsRelationshipHandler relationshipHandler = new ElementsRelationshipHandler(elementsAPI, objectStore, objectsInRelationships);
        for (ElementsRelationshipObserver relationshipObserver : relationshipObservers) {
            relationshipHandler.addObserver(relationshipObserver);
        }

        elementsAPI.execute(relationshipFeedQuery, relationshipHandler);

        TranslationService.shutdown();

        for (String category : objectsToHarvest.split("\\s*,\\s*")) {
            ElementsObjectCategory eoCategory = ElementsObjectCategory.valueOf(category);
            if (eoCategory != null && eoCategory != ElementsObjectCategory.USER) {
                // Delete the RDF objects not marked to be kept
                rdfStore.pruneExcept(eoCategory, objectsInRelationships.get(eoCategory));
            }
        }
    }
}

