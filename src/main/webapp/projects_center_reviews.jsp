<%--
  ~ ConcourseConnect
  ~ Copyright 2009 Concursive Corporation
  ~ http://www.concursive.com
  ~
  ~ This file is part of ConcourseConnect, an open source social business
  ~ software and community platform.
  ~
  ~ Concursive ConcourseConnect is free software: you can redistribute it and/or
  ~ modify it under the terms of the GNU Affero General Public License as published
  ~ by the Free Software Foundation, version 3 of the License.
  ~
  ~ Under the terms of the GNU Affero General Public License you must release the
  ~ complete source code for any application that uses any part of ConcourseConnect
  ~ (system header files and libraries used by the operating system are excluded).
  ~ These terms must be included in any work that has ConcourseConnect components.
  ~ If you are developing and distributing open source applications under the
  ~ GNU Affero General Public License, then you are free to use ConcourseConnect
  ~ under the GNU Affero General Public License.
  ~
  ~ If you are deploying a web site in which users interact with any portion of
  ~ ConcourseConnect over a network, the complete source code changes must be made
  ~ available.  For example, include a link to the source archive directly from
  ~ your web site.
  ~
  ~ For OEMs, ISVs, SIs and VARs who distribute ConcourseConnect with their
  ~ products, and do not license and distribute their source code under the GNU
  ~ Affero General Public License, Concursive provides a flexible commercial
  ~ license.
  ~
  ~ To anyone in doubt, we recommend the commercial license. Our commercial license
  ~ is competitively priced and will eliminate any confusion about how
  ~ ConcourseConnect can be used and distributed.
  ~
  ~ ConcourseConnect is distributed in the hope that it will be useful, but WITHOUT
  ~ ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  ~ FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
  ~ details.
  ~
  ~ You should have received a copy of the GNU Affero General Public License
  ~ along with ConcourseConnect.  If not, see <http://www.gnu.org/licenses/>.
  ~
  ~ Attribution Notice: ConcourseConnect is an Original Work of software created
  ~ by Concursive Corporation
  --%>
<%@ taglib uri="/WEB-INF/portlet.tld" prefix="portlet" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/concourseconnect-taglib.tld" prefix="ccp" %>
<%@ page import="com.concursive.connect.web.modules.login.dao.User" %>
<%@ page import="com.concursive.connect.web.modules.reviews.dao.ProjectRating" %>
<%@ page import="com.concursive.connect.web.modules.profile.utils.ProjectUtils" %>
<jsp:useBean id="User" class="com.concursive.connect.web.modules.login.dao.User" scope="session"/>
<jsp:useBean id="project" class="com.concursive.connect.web.modules.profile.dao.Project" scope="request"/>
<jsp:useBean id="projectRatingList" class="com.concursive.connect.web.modules.reviews.dao.ProjectRatingList" scope="request"/>
<jsp:useBean id="userReviewId" class="java.lang.String" scope="request"/>
<%@ include file="initPage.jsp" %>
<portlet:defineObjects/>
  <%--<h1><ccp:tabLabel name="Reviews" object="project"/></h1>--%>
  <ccp:evaluate if="<%= !User.isLoggedIn() && project.getFeatures().getAllowGuests() %>">
    <span><em><ccp:label name="projectsCenterReviews.loginToRateThisItem">Sign in to create a review.</ccp:label></em></span>
  </ccp:evaluate>
  <%--<ccp:permission name="project-reviews-add">
    <ccp:evaluate if="<%= User.isLoggedIn() && project.getOwner() != User.getId() %>">
      <ccp:evaluate if="<%= \"-1\".equals(userReviewId) %>">
        <portlet:renderURL var="addUrl">
          <portlet:param name="portlet-action" value="create"/>
          <portlet:param name="portlet-object" value="review"/>
        </portlet:renderURL>
        <span><a href="${addUrl}">Add a Review</a></span>
      </ccp:evaluate>
      <ccp:evaluate if="<%= !\"-1\".equals(userReviewId) %>">
        <portlet:renderURL var="updateUrl">
          <portlet:param name="portlet-action" value="modify"/>
          <portlet:param name="portlet-object" value="review"/>
          <portlet:param name="portlet-value" value="${userReviewId}"/>
        </portlet:renderURL>
        <span><a href="${updateUrl}">Update your Review</a></span>
      </ccp:evaluate>
    </ccp:evaluate>
  </ccp:permission>
    <c:if test="${!empty projectRatingList}">
      <div class="rating">
        <span class="averageRating">Average Rating</span>
        <ccp:rating id='<%= project.getId() %>'
                   showText='true'
                   count='<%= project.getRatingCount() %>'
                   value='<%= project.getRatingValue() %>'
                   url='' />
      </div>
    </c:if>--%>
  <%= showError(request, "actionError") %>

  <%-- Box for column --%>
  <c:choose>
    <c:when test="<%= projectRatingList.isEmpty() %>">
      <ccp:label name="projectsCenterReviews.noAds">There are currently no reviews to display.</ccp:label>
    </c:when>
    <c:otherwise>
      <%-- sorting bars --%>
      <div>
        <portlet:renderURL var="sortByUsefulUrl">
          <portlet:param name="portlet-action" value="show"/>
          <portlet:param name="portlet-object" value="reviews"/>
          <portlet:param name="portlet-value" value="useful"/>
        </portlet:renderURL>
        <portlet:renderURL var="sortByRecentUrl">
          <portlet:param name="portlet-action" value="show"/>
          <portlet:param name="portlet-object" value="reviews"/>
          <portlet:param name="portlet-value" value="recent"/>
        </portlet:renderURL>
        Sort by
        <a href="${sortByUsefulUrl}">most useful</a> or
        <a href="${sortByRecentUrl}">most recent</a>
      </div>
    </c:otherwise>
  </c:choose>
  <div id="message" class="menu">
    <p>Thank you for your valuable feedback.</p>
  </div>
  <%-- begin ratings --%>
  <%
    Iterator i = projectRatingList.iterator();
    while (i.hasNext()) {
      ProjectRating thisProjectRating = (ProjectRating) i.next();
      request.setAttribute("thisProjectRating", thisProjectRating);
  %>
  <div class="userInputContainer">
    <div class="userInputBody">
      <div class="userInputHeader">
        <div class="header">
          <h3><%= toHtml(thisProjectRating.getTitle()) %></h3>
        </div>
        <div class="rating">
          <ccp:rating id='<%= project.getId() %>'
                         showText='false'
                         count='1'
                         value='<%= thisProjectRating.getRating() %>'
                         url='' />
        </div>
      </div>
      <p><%= toHtml(thisProjectRating.getComment()) %></p>
      <ccp:evaluate if="<%= thisProjectRating.getRatingCount() > 0 %>">
        <p>(<%= thisProjectRating.getRatingValue() %> out of <%= thisProjectRating.getRatingCount() %> <%= thisProjectRating.getRatingCount() == 1 ? " person" : " people"%> found this review useful.)</p>
      </ccp:evaluate>
      <ccp:evaluate if="<%= thisProjectRating.getInappropriateCount() > 0 && ProjectUtils.hasAccess(thisProjectRating.getProjectId(), User, \"project-reviews-admin\")%>">
        <p>(<%= thisProjectRating.getInappropriateCount() %><%= thisProjectRating.getInappropriateCount() == 1? " person" : " people"%> found this review inappropriate.)</p>
      </ccp:evaluate>
      <ccp:permission name="project-reviews-add,project-reviews-admin" if="any">
        <div class="permissions">
          <ccp:permission name="project-reviews-add">
            <%-- edit review if you have admin privileges (or) if you are the author --%>
            <ccp:evaluate if="<%= (ProjectUtils.hasAccess(thisProjectRating.getProjectId(), User, \"project-reviews-admin\") || (thisProjectRating.getEnteredBy() == User.getId()))%>">
              <portlet:renderURL var="updateUrl">
                <portlet:param name="portlet-action" value="modify"/>
                <portlet:param name="portlet-object" value="review"/>
                <portlet:param name="portlet-value" value="${thisProjectRating.id}"/>
              </portlet:renderURL>
	              <a href="${updateUrl}"><img src="<%= ctx %>/images/icons/stock_edit-16.gif" border="0" align="absmiddle" title="<ccp:label name="projectsCenterReviews.byReview.editThisItem">Edit this item</ccp:label>"></a>
            </ccp:evaluate>
          </ccp:permission>
          <ccp:permission name="project-reviews-admin">
            <%-- delete review --%>
            <portlet:actionURL var="deleteUrl">
              <portlet:param name="portlet-action" value="show"/>
              <portlet:param name="portlet-object" value="reviews"/>
              <portlet:param name="portlet-value" value="${thisProjectRating.id}"/>
              <portlet:param name="portlet-command" value="delete"/>
            </portlet:actionURL>
	            <a href="javascript:confirmDelete('${deleteUrl}');"><img src="<%= ctx %>/images/icons/stock_delete-16.gif" border="0" align="absmiddle" title="<ccp:label name="projectsCenterReviews.byReview.deleteThisItem">Delete this item</ccp:label>"></a>
          </ccp:permission>
        </div>
      </ccp:permission>
    </div>
    <div class="userInputDetails">
      <div class="projectCenterProfileImage">
        <c:if test="${!empty thisProjectRating.project.category.logo}">
          <div class="imageContainer">
            <c:choose>
              <c:when test="${!empty thisProjectRating.user.profileProject.logo}">
                <img alt="<c:out value="${thisProjectRating.project.title}"/> photo" src="${ctx}/image/<%= thisProjectRating.getUser().getProfileProject().getLogo().getUrlName(50,50) %>" width="50" height="50" />
              </c:when>
              <c:when test="${!empty thisProjectRating.user.profileProject.category.logo}">
                <img alt="Default user photo" src="${ctx}/image/<%= thisProjectRating.getUser().getProfileProject().getCategory().getLogo().getUrlName(50,50) %>" width="50" height="50" class="default-photo" />
              </c:when>
            </c:choose>
          </div>
        </c:if>
      </div>

      <div class="details">
        <ul>
          <li class="userName"><ccp:username id="<%= thisProjectRating.getEnteredBy() %>"/></li>
          <ccp:evaluate if="<%= thisProjectRating.getEnteredBy() != thisProjectRating.getModifiedBy() %>">
            <li class="modifiedName">Modified By:<span><ccp:username id="<%= thisProjectRating.getModifiedBy() %>"/></span></li>
          </ccp:evaluate>
          <li class="date"><ccp:tz timestamp="<%= thisProjectRating.getModified() %>" dateFormat="<%= DateFormat.SHORT %>" default="&nbsp;"/></li>
        </ul>
      </div>
    </div>
    <div class="userInputFooter">
       <ccp:permission name="project-reviews-view">
        <%-- any user who is not the author of the review can mark the rate the review  --%>
        <ccp:evaluate if="<%= (thisProjectRating.getEnteredBy() != User.getId())  && User.isLoggedIn() %>">
          <p>Is this review useful?
          <portlet:renderURL var="ratingUrl" windowState="maximized">
            <portlet:param name="portlet-command" value="setRating"/>
            <portlet:param name="id" value="${thisProjectRating.id}"/>
            <portlet:param name="v" value="1"/>
            <portlet:param name="out" value="text"/>
          </portlet:renderURL>
          <a href="javascript:copyRequest('${ratingUrl}','<%= "message_" + thisProjectRating.getId() %>','message');">Yes</a>&nbsp;
          <portlet:renderURL var="ratingUrl" windowState="maximized">
            <portlet:param name="portlet-command" value="setRating"/>
            <portlet:param name="id" value="${thisProjectRating.id}"/>
            <portlet:param name="v" value="0"/>
            <portlet:param name="out" value="text"/>
          </portlet:renderURL>
          <a href="javascript:copyRequest('${ratingUrl}','<%= "message_" + thisProjectRating.getId() %>','message');">No</a>&nbsp;
     	  <ccp:evaluate if="<%= thisProjectRating.getId() > -1 && User.isLoggedIn() %>">
 			<a href="javascript:showPanel('Mark this review as Inappropriate','${ctx}/show/${project.uniqueId}/app/report_inappropriate?module=reviews&pid=${project.id}&id=${thisProjectRating.id}',700)">Report this as inappropriate</a>
 		  </ccp:evaluate>
 		  </p>
          <div id="message_<%= thisProjectRating.getId() %>"></div>
        </ccp:evaluate>
       </ccp:permission>
    </div>
  </div>
  <%
    }
  %>
