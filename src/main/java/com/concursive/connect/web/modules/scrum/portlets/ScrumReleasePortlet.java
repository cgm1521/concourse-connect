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
package com.concursive.connect.web.modules.scrum.portlets;

import com.concursive.connect.Constants;
import com.concursive.connect.cms.portal.dao.ProjectItem;
import com.concursive.connect.cms.portal.dao.ProjectItemList;
import com.concursive.connect.web.modules.lists.dao.TaskCategory;
import com.concursive.connect.web.modules.lists.dao.TaskCategoryList;
import com.concursive.connect.web.modules.lists.dao.TaskList;
import com.concursive.connect.web.modules.profile.dao.Project;
import com.concursive.connect.web.portal.PortalUtils;

import javax.portlet.*;
import java.io.IOException;
import java.sql.Connection;
import java.util.LinkedHashMap;

/**
 * Displays target releases and associated stories and a list of status
 *
 * @author matt rajkowski
 * @version $Id$
 * @created January 19, 2008
 */
public class ScrumReleasePortlet extends GenericPortlet {
  private static final String VIEW_PAGE = "/portlets/scrum_release/scrum_release-view.jsp";
  private static final String EDIT_PAGE = "/portlets/scrum_release/scrum_release-edit.jsp";
  private static final String HELP_PAGE = "/portlets/scrum_release/scrum_release-help.jsp";
  private static final String NOT_CONFIGURED_PAGE = "/portlets/not_configured.jsp";

  // GenericPortlet Impl -----------------------------------------------------

  public void doView(RenderRequest request, RenderResponse response)
      throws PortletException, IOException {
    if (System.getProperty("DEBUG") != null) {
      System.out.println("ScrumReleasePortlet-> doView");
    }
    try {
      PortletContext context = getPortletContext();
      // Preferences
      String categoryId = request.getPreferences().getValue("categoryId", "-1");
      request.setAttribute("categoryId", categoryId);

      if ("-1".equals(categoryId)) {
        // Portlet is not configured
        PortletRequestDispatcher requestDispatcher =
            context.getRequestDispatcher(NOT_CONFIGURED_PAGE);
        requestDispatcher.include(request, response);
      } else {
        // Portlet is configured
        Connection db = PortalUtils.useConnection(request);
        Project thisProject = PortalUtils.getProject(request);
        TaskCategory category = new TaskCategory(db, Integer.parseInt(categoryId));
        request.setAttribute("category", category);

        // Cross reference the open target releases with the stories
        ProjectItemList targetReleaseList = new ProjectItemList();
        targetReleaseList.setProjectId(thisProject.getId());
        targetReleaseList.setEnabled(Constants.TRUE);
        targetReleaseList.buildList(db, ProjectItemList.LIST_TARGET_RELEASE);

        LinkedHashMap<ProjectItem, TaskList> releaseStatusList = new LinkedHashMap<ProjectItem, TaskList>();
        for (Object thisReleaseItem : targetReleaseList) {
          ProjectItem thisRelease = (ProjectItem) thisReleaseItem;
          TaskList storiesList = new TaskList();
          storiesList.setProjectId(thisProject.getId());
          storiesList.setCategoryId(Integer.parseInt(categoryId));
          storiesList.setTargetRelease(thisRelease.getId());
          storiesList.setComplete(Constants.FALSE);
          storiesList.buildList(db);
          if (storiesList.size() > 0) {
            releaseStatusList.put(thisRelease, storiesList);
          }
        }
        request.setAttribute("releaseStatusList", releaseStatusList);

        // Cross reference the open target releases with the stories
        ProjectItemList statusList = new ProjectItemList();
        statusList.setProjectId(thisProject.getId());
        statusList.buildList(db, ProjectItemList.LIST_STATUS);
        request.setAttribute("statusList", statusList);

        // Cross reference the open target releases with the stories
        ProjectItemList remainingWorkList = new ProjectItemList();
        remainingWorkList.setProjectId(thisProject.getId());
        remainingWorkList.buildList(db, ProjectItemList.LIST_LOE_REMAINING);
        request.setAttribute("remainingWorkList", remainingWorkList);

        PortletRequestDispatcher requestDispatcher =
            context.getRequestDispatcher(VIEW_PAGE);

        requestDispatcher.include(request, response);
      }
    } catch (Exception e) {
      throw new PortletException(e.getMessage());
    }

  }

  protected void doEdit(RenderRequest request, RenderResponse response)
      throws PortletException, IOException {
    if (System.getProperty("DEBUG") != null) {
      System.out.println("ScrumReleasePortlet-> doEdit");
    }
    try {
      Connection db = PortalUtils.useConnection(request);
      // Get the categories for the user
      TaskCategoryList categoryList = new TaskCategoryList();
      categoryList.setProjectId(PortalUtils.getProject(request).getId());
      categoryList.buildList(db);
      request.setAttribute("categoryList", categoryList);
      // Show the edit page
      PortletContext context = getPortletContext();
      PortletRequestDispatcher requestDispatcher =
          context.getRequestDispatcher(EDIT_PAGE);
      requestDispatcher.include(request, response);
    } catch (Exception e) {

    }

  }

  protected void doHelp(RenderRequest request, RenderResponse response)
      throws PortletException, IOException {
    if (System.getProperty("DEBUG") != null) {
      System.out.println("ScrumReleasePortlet-> doHelp");
    }
    PortletContext context = getPortletContext();
    PortletRequestDispatcher requestDispatcher =
        context.getRequestDispatcher(HELP_PAGE);
    requestDispatcher.include(request, response);
  }

  public void processAction(ActionRequest request, ActionResponse response)
      throws PortletException, IOException {
    String categoryId = request.getParameter("categoryId");
    PortletPreferences prefs = request.getPreferences();
    prefs.setValue("categoryId", categoryId);
    prefs.store();
  }
}