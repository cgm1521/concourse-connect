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
package com.concursive.connect.web.modules.promotions.portlets;

import com.concursive.commons.text.StringUtils;
import com.concursive.connect.Constants;
import com.concursive.connect.web.modules.login.dao.User;
import com.concursive.connect.web.modules.profile.dao.Project;
import com.concursive.connect.web.modules.profile.dao.ProjectCategoryList;
import com.concursive.connect.web.modules.promotions.dao.AdList;
import com.concursive.connect.web.portal.PortalUtils;
import com.concursive.connect.web.utils.PagedListInfo;

import javax.portlet.*;
import java.io.IOException;
import java.sql.Connection;

/**
 * Project Promotions portlet
 *
 * @author Kailash Bhoopalam
 * @created July 10, 2008
 */
public class ProjectPromotionsPortlet extends GenericPortlet {

  // Pages
  private static final String VIEW_PAGE = "/portlets/project_promotions/project_promotions-view.jsp";

  // Preferences
  private static final String PREF_TITLE = "title";
  private static final String PREF_LIMIT = "limit";
  private static final String PREF_CATEGORY = "category";

  // Request Attributes
  private static final String PROJECT_AD_LIST = "adList";
  private static final String PROJECT_CATEGORY_LIST = "projectCategoryList";
  private static final String TITLE = "title";

  public void doView(RenderRequest request, RenderResponse response)
      throws PortletException, IOException {
    try {
      // The JSP to show upon success
      String defaultView = VIEW_PAGE;

      // Determine the current user
      User thisUser = PortalUtils.getUser(request);

      // General display preferences
      request.setAttribute(TITLE, request.getPreferences().getValue(PREF_TITLE, ""));
      String limit = request.getPreferences().getValue(PREF_LIMIT, "-1");

      // Check for a specific category
      String categoryName = request.getPreferences().getValue(PREF_CATEGORY, "");
      // Check any generated data
      for (String event : PortalUtils.getDashboardPortlet(request).getConsumeDataEvents()) {
        // Detects if another instance of this portlet is showing categories
        if (event.toLowerCase().equals("category")) {
          categoryName = (String) PortalUtils.getGeneratedData(request, event);
        }
      }

      // Check the current project profile page if a category is not specified
      Project project = null;
      if (!StringUtils.hasText(categoryName)) {
        project = PortalUtils.findProject(request);
      }

      // Use the valid categories
      ProjectCategoryList categories = (ProjectCategoryList) request.getAttribute(Constants.REQUEST_TAB_CATEGORY_LIST);
      request.setAttribute(PROJECT_CATEGORY_LIST, categories);

      // Determine the actual category
      int categoryId = -1;
      if (StringUtils.hasText(categoryName)) {
        // Use the current category
        if ("${category}".equals(categoryName)) {
          Project thisProject = PortalUtils.findProject(request);
          if (thisProject != null) {
            categoryName = categories.getValueFromId(thisProject.getCategoryId());
          }
        }
        categoryId = categories.size() > 0 ? categories.getIdFromValue(categoryName) : -1;
      }

      // Determine the database connection to use
      Connection db = PortalUtils.getConnection(request);

      // Ads to show - use paged data for sorting
      PagedListInfo pagedListInfo = new PagedListInfo();
      pagedListInfo.setItemsPerPage(limit);
      pagedListInfo.setRandomOrder(true);

      AdList adList = new AdList();
      adList.setPagedListInfo(pagedListInfo);
      if (project == null) {
        adList.setInstanceId(PortalUtils.getInstance(request).getId());
      }
      adList.setGroupId(thisUser.getGroupId());
      if (categoryId > -1) {
        adList.setProjectCategoryId(categoryId);
        adList.setOpenProjectsOnly(true);
      } else if (project != null) {
        adList.setProjectId(project.getId());
      }
      if (PortalUtils.getDashboardPortlet(request).isCached()) {
        if (PortalUtils.canShowSensitiveData(request)) {
          // Use the most generic settings since this portlet is cached
          adList.setForParticipant(Constants.TRUE);
        } else {
          // Use the most generic settings since this portlet is cached
          adList.setPublicProjects(Constants.TRUE);
        }
      } else {
        // Use the current user's setting
        thisUser = PortalUtils.getUser(request);
        adList.setForUser(thisUser.getId());
      }
      adList.setCurrentAds(Constants.TRUE);
      adList.setPublished(Constants.TRUE);
      adList.setEnabled(Constants.TRUE);
      adList.buildList(db);
      request.setAttribute(PROJECT_AD_LIST, adList);

      // JSP view
      if (adList.size() > 0) {
        PortletContext context = getPortletContext();
        PortletRequestDispatcher requestDispatcher =
            context.getRequestDispatcher(defaultView);
        requestDispatcher.include(request, response);
      }
    } catch (Exception e) {
      throw new PortletException(e.getMessage());
    }
  }
}
