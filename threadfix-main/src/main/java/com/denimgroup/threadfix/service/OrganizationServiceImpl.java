////////////////////////////////////////////////////////////////////////
//
//     Copyright (c) 2009-2014 Denim Group, Ltd.
//
//     The contents of this file are subject to the Mozilla Public License
//     Version 2.0 (the "License"); you may not use this file except in
//     compliance with the License. You may obtain a copy of the License at
//     http://www.mozilla.org/MPL/
//
//     Software distributed under the License is distributed on an "AS IS"
//     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
//     License for the specific language governing rights and limitations
//     under the License.
//
//     The Original Code is ThreadFix.
//
//     The Initial Developer of the Original Code is Denim Group, Ltd.
//     Portions created by Denim Group, Ltd. are Copyright (C)
//     Denim Group, Ltd. All Rights Reserved.
//
//     Contributor(s): Denim Group, Ltd.
//
////////////////////////////////////////////////////////////////////////
package com.denimgroup.threadfix.service;

import com.denimgroup.threadfix.data.dao.OrganizationDao;
import com.denimgroup.threadfix.data.entities.AccessControlTeamMap;
import com.denimgroup.threadfix.data.entities.Application;
import com.denimgroup.threadfix.data.entities.Organization;
import com.denimgroup.threadfix.data.entities.Permission;
import com.denimgroup.threadfix.logging.SanitizedLogger;
import com.denimgroup.threadfix.service.util.PermissionUtils;
import org.jetbrains.annotations.Nullable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@Transactional(readOnly = true)
public class OrganizationServiceImpl implements OrganizationService {
	
	protected final SanitizedLogger log = new SanitizedLogger(OrganizationService.class);

    @Autowired
	private OrganizationDao organizationDao = null;
    @Autowired
	private ApplicationService applicationService = null;
    @Autowired(required = false)
    @Nullable
	private PermissionService permissionService = null;
    @Autowired
	private AccessControlMapService accessControlMapService = null;

	@Override
	public List<Organization> loadAllActive() {
		return organizationDao.retrieveAllActive();
	}

	@Override
	public List<Organization> loadAllNoOrder() {
		return organizationDao.retrieveAllNoOrder();
	}

	@Override
	public Organization loadOrganization(int organizationId) {
		return organizationDao.retrieveById(organizationId);
	}

	@Override
	public Organization loadOrganization(String name) {
		return organizationDao.retrieveByName(name);
	}

	@Override
	@Transactional(readOnly = false)
	public void storeOrganization(Organization organization) {
		organizationDao.saveOrUpdate(organization);
	}

	@Override
	@Transactional(readOnly = false)
	public void deactivateOrganization(Organization organization) {
		log.warn("Deleting organization with ID " + organization.getId());
		
		organization.setActive(false);
		
		organization.setName("deleted-" + organization.getId() + "-" + organization.getName());
		if (organization.getName().length() >= Organization.NAME_LENGTH) {
			organization.setName(organization.getName().substring(0, Organization.NAME_LENGTH - 2));
		}
		
		organization.setModifiedDate(new Date());
		
		if (organization.getActiveApplications() != null) {
			for (Application app : organization.getActiveApplications()) {
				applicationService.deactivateApplication(app);
			}
		}
		
		if (organization.getAccessControlTeamMaps() != null) {
			for (AccessControlTeamMap map : organization.getAccessControlTeamMaps()) {
				accessControlMapService.deactivate(map);
			}
		}
		
		organizationDao.saveOrUpdate(organization);
	}
	
	// TODO make this better
	public boolean isValidOrganization(Organization organization) {

		return organization != null && organization.getName() != null 
				&& !organization.getName().trim().isEmpty() 
				&& organization.getName().length() < Organization.NAME_LENGTH
				&& loadOrganization(organization.getName()) == null;
	}
	
	@Override
	public List<Organization> loadAllActiveFilter() {
		if (!EnterpriseTest.isEnterprise() || PermissionUtils.hasGlobalPermission(Permission.READ_ACCESS))
			return loadAllActive();

        if (permissionService == null) {
            throw new IllegalStateException("EnterpriseTest.isEnterprise returned true but permissionService is null. " +
                    "Fix the code.");
        }

		Set<Integer> ids = permissionService.getAuthenticatedTeamIds();
		
		Set<Integer> teamIds;
		
		if (ids == null || ids.isEmpty()) {
			teamIds = new HashSet<>();
		} else {
			teamIds = new HashSet<>(ids);
		}
		
		// Also add in the teams that only have app permissions
		Set<Integer> appIds = permissionService.getAuthenticatedAppIds();
		if (appIds != null && !appIds.isEmpty()) {
			for (Integer id : appIds) {
				Application app = applicationService.loadApplication(id);
				if (app != null && app.getOrganization() != null && 
						app.getOrganization().getId() != null && 
						!teamIds.contains(app.getOrganization().getId())) {
					teamIds.add(app.getOrganization().getId());
				}
			}
		}
		
		if (teamIds.size() == 0) {
			return new ArrayList<>();
		}
		
		return organizationDao.retrieveAllActiveFilter(teamIds);
	}
	
}
