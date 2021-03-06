<%@ include file="/common/taglibs.jsp"%>

<div class="modal-header">
	<h4 id="myModalLabel">Permissible Users</h4>
</div>

<div class="modal-body">
	<table class="table table-striped">
		<thead>
			<tr>
				<th class="medium first">User</th>
				<th class="short">Role</th>
				<th class="short"></th>
			</tr>
		</thead>
		<tbody id="userTableBody">
		<c:forEach var="user" items="${ users }" varStatus="status">
			<tr class="bodyRow">
				<td id="name${ status.count }">
					<c:out value="${ user.name }"/>
				</td>
				<td id="role${ status.count }">
					<c:if test="${ user.hasGlobalGroupAccess }">
						<c:out value="${ user.globalRole.displayName }"/>
					</c:if>
					<c:if test="${ not user.hasGlobalGroupAccess }">
						<c:set var="isDisplayedAppRole" value="false"/>
						<c:set var="isDisplayedTeamRole" value="false"/>
						<c:forEach var="mapTeam" items="${ user.accessControlTeamMaps }" varStatus="status">
							<c:if test="${ mapTeam.organization.id == organization.id && mapTeam.organization.id != application.organization.id && not isDisplayedTeamRole }">
								<c:set var="isDisplayedTeamRole" value="true"/>
								<c:if test="${ mapTeam.allApps }"><c:out value="${ mapTeam.role.displayName }"/></c:if>
								<c:if test="${ not mapTeam.allApps }">
									Read Access
								</c:if>
							</c:if>
							<c:if test="${ mapTeam.organization.id == application.organization.id }">
								<c:if test="${ mapTeam.allApps }"><c:out value="${ mapTeam.role.displayName }"/></c:if>
								<c:if test="${ not mapTeam.allApps }">
									<c:forEach varStatus="status1" var="appMap" items="${ mapTeam.accessControlApplicationMaps }">
										<c:if test="${ appMap.application.id == application.id && not isDisplayedAppRole }">
											<c:set var="isDisplayedAppRole" value="true"/>
											<c:out value="${ appMap.role.displayName }"/>
										</c:if>
									</c:forEach>
								</c:if>
							</c:if>
						</c:forEach>
					</c:if>
				</td>
				<td id="name${ status.count }">
					<spring:url value="/configuration/users/{userId}/permissions" var="editPermissionsUrl">
						<spring:param name="userId" value="${ user.id }"/>
					</spring:url>
					<a id="editPermissions${ status.count }" style="font-size:12px;float:right;" href="${ fn:escapeXml(editPermissionsUrl) }">Edit Permissions</a>
				</td>
			</tr>
		</c:forEach>
		</tbody>
	</table>
</div>
<div class="modal-footer">
		<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
</div>