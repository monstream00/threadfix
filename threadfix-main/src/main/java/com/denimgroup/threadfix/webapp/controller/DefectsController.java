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
package com.denimgroup.threadfix.webapp.controller;

import com.denimgroup.threadfix.data.entities.Application;
import com.denimgroup.threadfix.data.entities.Defect;
import com.denimgroup.threadfix.data.entities.Permission;
import com.denimgroup.threadfix.data.entities.Vulnerability;
import com.denimgroup.threadfix.logging.SanitizedLogger;
import com.denimgroup.threadfix.service.ApplicationService;
import com.denimgroup.threadfix.service.DefectService;
import com.denimgroup.threadfix.service.VulnerabilityService;
import com.denimgroup.threadfix.service.queue.QueueSender;
import com.denimgroup.threadfix.service.util.ControllerUtils;
import com.denimgroup.threadfix.service.util.PermissionUtils;
import com.denimgroup.threadfix.webapp.viewmodels.DefectViewModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Controller
@RequestMapping("/organizations/{orgId}/applications/{appId}/defects")
@SessionAttributes("defectViewModel")
public class DefectsController {
	
	public DefectsController(){}
	
	private final SanitizedLogger log = new SanitizedLogger(DefectsController.class);

	private ApplicationService applicationService;
	private QueueSender queueSender;
	private VulnerabilityService vulnerabilityService;
	private DefectService defectService;

	@Autowired
	public DefectsController(ApplicationService applicationService, 
			QueueSender queueSender,
			VulnerabilityService vulnerabilityService,
			DefectService defectService) {
		this.queueSender = queueSender;
		this.applicationService = applicationService;
		this.vulnerabilityService = vulnerabilityService;
		this.defectService = defectService;
	}

	@RequestMapping(method = RequestMethod.POST)
	public String onSubmit(@PathVariable("orgId") int orgId, @PathVariable("appId") int appId,
			@ModelAttribute DefectViewModel defectViewModel, ModelMap model,
			HttpServletRequest request) {
		
		if (!PermissionUtils.isAuthorized(Permission.CAN_SUBMIT_DEFECTS, orgId, appId)) {
			return "403";
		}
		
		if (defectViewModel.getVulnerabilityIds() == null
				|| defectViewModel.getVulnerabilityIds().size() == 0) {
			log.info("No vulnerabilities selected for Defect submission.");
			String message = "You must select at least one vulnerability.";
			ControllerUtils.addErrorMessage(request, message);
			model.addAttribute("contentPage", "/organizations/" + orgId + "/applications/" + appId);
			return "ajaxRedirectHarness";
		}

		List<Vulnerability> vulnerabilities = vulnerabilityService.loadVulnerabilityList(defectViewModel.getVulnerabilityIds());
		Defect newDefect = defectService.createDefect(vulnerabilities, defectViewModel.getSummary(), 
				defectViewModel.getPreamble(), 
				defectViewModel.getSelectedComponent(), 
				defectViewModel.getVersion(), 
				defectViewModel.getSeverity(), 
				defectViewModel.getPriority(), 
				defectViewModel.getStatus());
		
		if (newDefect != null)
			ControllerUtils.addSuccessMessage(request, "The Defect was submitted to the tracker.");
		else 
			ControllerUtils.addErrorMessage(request, "The Defect couldn't be submitted to the tracker.");
		model.addAttribute("contentPage", "/organizations/" + orgId + "/applications/" + appId);
		return "ajaxRedirectHarness";
	}

	@RequestMapping(value = "/update", method = RequestMethod.GET)
	public String updateVulnsFromDefectTracker(@PathVariable("orgId") int orgId,
			@PathVariable("appId") int appId,
			HttpServletRequest request) {
		
		if (!PermissionUtils.isAuthorized(Permission.READ_ACCESS, orgId, appId)) {
			return "403";
		}
		
		Application app = applicationService.loadApplication(appId);
		
		if (app == null || app.getOrganization() == null || app.getOrganization().getId() == null) {
			log.warn(ResourceNotFoundException.getLogMessage("Application", appId));
			throw new ResourceNotFoundException();
		}
		
		queueSender.addDefectTrackerVulnUpdate(orgId, appId);
		
		ControllerUtils.addSuccessMessage(request, 
				"The Defect Tracker update request was submitted to the tracker.");

		return "redirect:/organizations/" + app.getOrganization().getId() + 
				"/applications/" + app.getId();
	}

	@RequestMapping(value = "/merge", method = RequestMethod.POST)
	public String onMerge(@PathVariable("orgId") int orgId, @PathVariable("appId") int appId,
			@ModelAttribute DefectViewModel defectViewModel, ModelMap model,
			HttpServletRequest request) {
		
		if (!PermissionUtils.isAuthorized(Permission.CAN_SUBMIT_DEFECTS, orgId, appId)) {
			return "403";
		}
		
		List<Integer> vulnerabilityIds = defectViewModel.getVulnerabilityIds();
		if (vulnerabilityIds == null || vulnerabilityIds.size() == 0) {
			log.info("No vulnerabilities selected for Defect merge.");
			String message = "You must select at least one vulnerability to merge.";
			ControllerUtils.addErrorMessage(request, message);
			model.addAttribute("contentPage", "/organizations/" + orgId + "/applications/" + appId);
			return "ajaxRedirectHarness";
		}
		
		List<Vulnerability> vulnerabilities = vulnerabilityService.loadVulnerabilityList(vulnerabilityIds);
		
		if (defectService.mergeDefect(vulnerabilities, defectViewModel.getId())) {
			ControllerUtils.addSuccessMessage(request, "Vulnerability(s) was merged to Defect ID " + defectViewModel.getId() + " of the tracker.");
		} else {
			ControllerUtils.addErrorMessage(request, "Vulnerability(s) could not be merged to Defect ID " + defectViewModel.getId() + " of the tracker.");
		}
	
		model.addAttribute("contentPage", "/organizations/" + orgId + "/applications/" + appId);
		return "ajaxRedirectHarness";
	}
}
