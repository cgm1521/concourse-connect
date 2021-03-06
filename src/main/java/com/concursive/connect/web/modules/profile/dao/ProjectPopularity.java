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

package com.concursive.connect.web.modules.profile.dao;

import com.concursive.connect.Constants;
import com.concursive.connect.web.modules.common.social.popularity.beans.PopularityCriteria;
import com.concursive.connect.web.modules.profile.utils.ProjectUtils;
import com.concursive.connect.web.utils.PagedListInfo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;

/**
 * Class to fetch results based on Project Popularity Criteria
 *
 * @author Kailash Bhoopalam
 * @version $Id$
 * @created June 4, 2008
 */
public class ProjectPopularity {

  public static ProjectList retrieveProjects(Connection db, PopularityCriteria popularityCriteria, int categoryId) throws SQLException {

    ArrayList<Integer> projectIds = new ArrayList<Integer>();

    StringBuffer sqlStatement = new StringBuffer();
    StringBuffer sqlOrder = new StringBuffer();

    PagedListInfo pagedListInfo = new PagedListInfo();
    pagedListInfo.setDefaultSort("points", popularityCriteria.getOrder());
    pagedListInfo.setItemsPerPage(popularityCriteria.getLimit());
    pagedListInfo.appendSqlTail(db, sqlOrder);
    pagedListInfo.appendSqlSelectHead(db, sqlStatement);

    // Views
    /*
    sqlStatement.append(" COUNT(*) AS points, v.project_id " +
        "FROM projects_view v, projects " +
        "WHERE v.project_id = projects.project_id " +
        "AND projects.category_id = ? " +
        "AND v.view_date <= ? " +
        "AND v.view_date > ? " +
        (popularityCriteria.getForPublic() == Constants.TRUE ? "AND projects.allow_guests = ? " : "") +
        (popularityCriteria.getForParticipant() == Constants.TRUE ? "AND (projects.allows_user_observers = ? OR projects.allow_guests = ?) " : "") +
        (popularityCriteria.getInstanceId() > -1 ? "AND projects.instance_id = ? " : "") +
        "AND projects.closedate IS NULL " +
        "GROUP BY v.project_id ");
    */

    // Ratings w/optional range
    sqlStatement.append(" SUM(rating) AS points, project_id " +
        "FROM projects_rating " +
        "WHERE project_id IN (SELECT project_id FROM projects WHERE category_id = ?) " +
        "AND entered <= ? " +
        (popularityCriteria.getStartDate() != null ? "AND entered > ? " : "") +
        (popularityCriteria.getForPublic() == Constants.TRUE ? "AND project_id IN (SELECT project_id FROM projects WHERE allow_guests = ? AND closedate IS NULL AND approvaldate IS NOT NULL) " : "") +
        (popularityCriteria.getForParticipant() == Constants.TRUE ? "AND project_id IN (SELECT project_id FROM projects WHERE (allows_user_observers = ? OR allow_guests = ?) AND closedate IS NULL AND approvaldate IS NOT NULL) " : "") +
        (popularityCriteria.getInstanceId() > -1 ? "AND project_id IN (SELECT project_id FROM projects WHERE instance_id = ?) " : "") +
        "GROUP BY project_id ");

    // Depth of Content w/optional range
    /*
    sqlStatement.append(" SUM(points) AS points, project_id " +
        "FROM user_contribution_log " +
        "WHERE project_id IN (SELECT project_id FROM projects WHERE category_id = ?) " +
        "AND contribution_date <= ? " +
        (popularityCriteria.getStartDate() != null ? "AND contribution_date > ? " : "") +
        (popularityCriteria.getForPublic() == Constants.TRUE ? "AND project_id IN (SELECT project_id FROM projects WHERE allow_guests = ? AND closedate IS NULL) " : "") +
        (popularityCriteria.getForParticipant() == Constants.TRUE ? "AND project_id IN (SELECT project_id FROM projects WHERE (allows_user_observers = ? OR allow_guests = ?) AND closedate IS NULL) " : "") +
        (popularityCriteria.getInstanceId() > -1 ? "AND project_id IN (SELECT project_id FROM projects WHERE instance_id = ?) " : "") +
        "GROUP BY project_id ");
    */
    ResultSet rs = null;
    PreparedStatement pst = db.prepareStatement(sqlStatement.toString() + sqlOrder.toString());
    int i = 0;
    pst.setInt(++i, categoryId);
    pst.setTimestamp(++i, popularityCriteria.getEndDate());
    if (popularityCriteria.getStartDate() != null) {
      pst.setTimestamp(++i, popularityCriteria.getStartDate());
    }
    if (popularityCriteria.getForPublic() == Constants.TRUE) {
      pst.setBoolean(++i, true);
    }
    if (popularityCriteria.getForParticipant() == Constants.TRUE) {
      pst.setBoolean(++i, true);
      pst.setBoolean(++i, true);
    }
    if (popularityCriteria.getInstanceId() > -1) {
      pst.setInt(++i, popularityCriteria.getInstanceId());
    }
    //System.out.println(pst);
    rs = pst.executeQuery();
    while (rs.next()) {
      int projectId = rs.getInt("project_id");
      projectIds.add(projectId);
    }
    rs.close();
    pst.close();
    // Return a project list
    Iterator<Integer> projectIdItr = projectIds.iterator();
    ProjectList projectList = new ProjectList();
    while (projectIdItr.hasNext()) {
      projectList.add(ProjectUtils.loadProject(projectIdItr.next()));
    }
    return projectList;
  }
}
