package com.denimgroup.threadfix.service.scans;

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.List;

import org.json.JSONException;
import org.junit.Ignore;
import org.junit.Test;

import com.denimgroup.threadfix.cli.ThreadFixRestClient;
import com.denimgroup.threadfix.service.merge.FrameworkType;
import com.denimgroup.threadfix.service.merge.SourceCodeAccessLevel;
import com.denimgroup.threadfix.service.merge.VulnTypeStrategy;
import com.denimgroup.threadfix.webservices.tests.BaseRestTest;

public class ScanMergeTests extends BaseRestTest {
	
	public static final boolean debug = true;
	
	static final ThreadFixRestClient GOOD_CLIENT = getGoodClient();

	@Test
	@Ignore
	public void testWavsepMerge() throws IOException, JSONException {
		testApplicationWithVariations(FrameworkType.JSP, WebApplication.WAVSEP);
	}
	
	@Test
	@Ignore
	public void testBodgeItMerge() throws IOException, JSONException {
		testApplicationWithVariations(FrameworkType.JSP, WebApplication.BODGEIT);
	}
	
	@Test
	public void testPetClinicMerge() throws IOException, JSONException {
		testApplicationWithVariations(FrameworkType.SPRING_MVC, WebApplication.PETCLINIC);
	}

	private void testApplicationWithVariations(FrameworkType frameworkType, WebApplication application) throws JSONException, IOException {
		debug("Starting " + application.getName() + " tests.");
		
		FileWriter fileWriter = null;
		try {
			fileWriter = new FileWriter(
					new File("C:\\test\\SBIR\\testoutput" + application.getName() + ".csv"));
			
			fileWriter.write("framework,source code access,vuln type strategy, total, correctly merged, correct path, correct param, correctCWE\n");
			
			// set up application
			// we pass in the type because we don't want to do a spring mvc run on a jsp app, for instance.
			for (FrameworkType type : new FrameworkType[] { FrameworkType.NONE, FrameworkType.DETECT, frameworkType }) {
				for (SourceCodeAccessLevel sourceCodeAccessLevel : SourceCodeAccessLevel.values()) {
					for (VulnTypeStrategy strategy : VulnTypeStrategy.values()) {
						testApplication(application, type, sourceCodeAccessLevel, strategy, fileWriter);
					}
				}
			}
		} finally {
			if (fileWriter != null) {
				fileWriter.close();
			}
		}
	}
	
	private void testApplication(WebApplication application, 
			FrameworkType frameworkType,
			SourceCodeAccessLevel sourceCodeAccessLevel, 
			VulnTypeStrategy vulnTypeStrategy,
			Writer writer) throws JSONException, IOException {
		
		Integer appId = setupApplication(application, frameworkType, sourceCodeAccessLevel, vulnTypeStrategy);

		String jsonToLookAt = GOOD_CLIENT.searchForApplicationById(appId.toString());
		
		// Parsing / analysis
		
		debug("Reading in manual merge results from JSON output.");
		List<SimpleVuln> jsonResults = SimpleVulnCollectionParser.parseVulnsFromJSON(jsonToLookAt);
		
		debug("Reading in manual merge results from CSV file.");
		List<SimpleVuln> csvResults  = SimpleVulnCollectionParser.parseVulnsFromMergeCSV(application);
		
		TestResult result = TestResult.compareResults(csvResults, jsonResults);
		
		writer.write(frameworkType + "," + sourceCodeAccessLevel + "," + vulnTypeStrategy);
		writer.write(result.getCsvLine() + "\n");
		
		if (result.hasMissing()) {
			System.out.println("We have more than 0 missing. " +
					"This means we need a better method of building the hash " +
					"or that native ID generation is incorrect.");
		}
	}
	
	private Integer setupApplication(WebApplication application, FrameworkType frameworkType,
			SourceCodeAccessLevel sourceCodeAccessLevel, VulnTypeStrategy vulnTypeStrategy) {
		debug("Creating new application and uploading scans.");
		
		Integer teamId = getId(getJSONObject(GOOD_CLIENT.createTeam(
				application.getName() + "-" + frameworkType + "-" + sourceCodeAccessLevel + "-" + vulnTypeStrategy
				)));
		Integer appId  = getId(getJSONObject(GOOD_CLIENT.createApplication(
			teamId.toString(), 
			application.getName() + getRandomString(10), 
			null)));
		
		GOOD_CLIENT.setParameters(appId.toString(), 
				vulnTypeStrategy.toString(), 
				sourceCodeAccessLevel.toString(), 
				frameworkType.toString(), 
				application.getUrl());

		uploadScans(appId, application.getFPRPath(), application.getAppscanXMLPath());

		debug("Application is at " + BASE_URL.replaceAll("/rest","") + 
				"/organizations/" + teamId + "/applications/" + appId);
		
		return appId;
	}
	
	private void uploadScans(Integer appId, String... scanPaths) {
		for (String scanPath : scanPaths) {
			debug("Uploading " + scanPath + " to application with ID " + appId);
			
			String response = GOOD_CLIENT.uploadScan(appId.toString(), scanPath);
			
			assertTrue(response != null);
			assertTrue(getJSONObject(response) != null);
		}
	}
	
	public void debug(String message) {
		if (debug) {
			System.out.println(message);
		}
	}
}