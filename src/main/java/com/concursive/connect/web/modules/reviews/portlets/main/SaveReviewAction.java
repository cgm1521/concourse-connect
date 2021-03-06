/*
 * ConcourseConnect
 * Copyright 2009 Concursive Corporation
 * http://www.concursive.com
 *
 * This file is part of ConcourseConnect, an open source social business
 * software and community platform.
 *
 * Concursive ConcourseConnect is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, version 3 of the License.
 *
 * Under the terms of the GNU Affero General Public License you must release the
 * complete source code for any application that uses any part of ConcourseConnect
 * (system header files and libraries used by the operating system are excluded).
 * These terms must be included in any work that has ConcourseConnect components.
 * If you are developing and distributing open source applications under the
 * GNU Affero General Public License, then you are free to use ConcourseConnect
 * under the GNU Affero General Public License.
 *
 * If you are deploying a web site in which users interact with any portion of
 * ConcourseConnect over a network, the complete source code changes must be made
 * available.  For example, include a link to the source archive directly from
 * your web site.
 *
 * For OEMs, ISVs, SIs and VARs who distribute ConcourseConnect with their
 * products, and do not license and distribute their source code under the GNU
 * Affero General Public License, Concursive provides a flexible commercial
 * license.
 *
 * To anyone in doubt, we recommend the commercial license. Our commercial license
 * is competitively priced and will eliminate any confusion about how
 * ConcourseConnect can be used and distributed.
 *
 * ConcourseConnect is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with ConcourseConnect.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Attribution Notice: ConcourseConnect is an Original Work of software created
 * by Concursive Corporation
 */
package com.concursive.connect.web.modules.reviews.portlets.main;

import com.concursive.commons.web.mvc.beans.GenericBean;
import com.concursive.connect.Constants;
import com.concursive.connect.web.modules.common.social.tagging.dao.UserTagLogList;
import com.concursive.connect.web.modules.login.dao.User;
import com.concursive.connect.web.modules.profile.dao.Project;
import com.concursive.connect.web.modules.profile.utils.ProjectUtils;
import com.concursive.connect.web.modules.reviews.dao.ProjectRating;
import com.concursive.connect.web.portal.IPortletAction;
import com.concursive.connect.web.portal.PortalUtils;
import static com.concursive.connect.web.portal.PortalUtils.*;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import java.sql.Connection;

/**
 * Action for saving a user's review
 *
 * @author matt rajkowski
 * @created October 27, 2008
 */
public class SaveReviewAction implements IPortletAction {

  public GenericBean processAction(ActionRequest request, ActionResponse response) throws Exception {

    // Determine the project container to use
    Project project = findProject(request);
    if (project == null) {
      throw new Exception("Project is null");
    }

    // Check the user's permissions
    User user = getUser(request);
    if (!ProjectUtils.hasAccess(project.getId(), user, "project-reviews-add")) {
      throw new PortletException("Unauthorized to add in this project");
    }

    // Populate any info from the request
    ProjectRating thisProjectRating = (ProjectRating) getFormBean(request, ProjectRating.class);

    // Set default values when saving records
    thisProjectRating.setProjectId(project.getId());
    thisProjectRating.setModifiedBy(user.getId());

    // Determine the database connection to use
    Connection db = useConnection(request);

    // Save the record
    boolean isNew = false;
    ProjectRating previousRating = null;
    if (thisProjectRating.getId() == -1) {
      // This appears to be a new review
      isNew = true;
      thisProjectRating.setEnteredBy(user.getId());
    } else {
      // Load the previous record
      previousRating = new ProjectRating(db, thisProjectRating.getId());
      thisProjectRating.setEnteredBy(previousRating.getEnteredBy());
      // Verify the record matches the specified project
      if (previousRating.getProjectId() != project.getId()) {
        throw new PortletException("Mismatched projectId found");
      }
    }
    boolean result = ProjectRating.save(db, thisProjectRating);
    if (!result) {
      return thisProjectRating;
    }

    //trigger the workflow
    if (isNew) {
      PortalUtils.processInsertHook(request, thisProjectRating);
    } else {
      PortalUtils.processUpdateHook(request, previousRating, thisProjectRating);
    }

    // Index the saved rating
    thisProjectRating = new ProjectRating(db, thisProjectRating.getId());
    indexAddItem(request, thisProjectRating);

    // Get the user's old tags and merge them with any new ones
    UserTagLogList tagLogList = new UserTagLogList();
    tagLogList.setUserId(thisProjectRating.getEnteredBy());
    tagLogList.setLinkModuleId(Constants.PROJECT_REVIEW_FILES);
    tagLogList.setLinkItemId(project.getId());
    tagLogList.buildList(db);

    // Merge the tags for updating
    String tags = request.getParameter("tags");
    tagLogList.updateTags(db, tags);

    // This call will close panels and perform redirects
    return (PortalUtils.performRefresh(request, response, "/show/reviews"));
  }
}
