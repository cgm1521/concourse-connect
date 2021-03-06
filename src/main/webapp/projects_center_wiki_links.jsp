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
<%@ taglib uri="/WEB-INF/concourseconnect-taglib.tld" prefix="ccp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.concursive.commons.http.RequestUtils" %>
<%@ page import="com.concursive.commons.text.StringUtils" %>
<jsp:useBean id="project" class="com.concursive.connect.web.modules.profile.dao.Project" scope="request"/>
<jsp:useBean id="targetWiki" class="com.concursive.connect.web.modules.wiki.dao.Wiki" scope="request"/>
<jsp:useBean id="link" class="java.lang.String" scope="request"/>
<%@ include file="initPage.jsp" %>
<script type="text/javascript" src="<%= RequestUtils.getAbsoluteServerUrl(request) %>/javascript/div.js?1"></script>
<script type="text/javascript" src="<%= RequestUtils.getAbsoluteServerUrl(request) %>/javascript/tiny_mce-3.2.7/tiny_mce_popup.js?1"></script>
<script type="text/javascript" src="<%= RequestUtils.getAbsoluteServerUrl(request) %>/javascript/tiny_mce-3.2.7/utils/mctabs.js"></script>
<script type="text/javascript" src="<%= RequestUtils.getAbsoluteServerUrl(request) %>/javascript/tiny_mce-3.2.7/utils/validate.js"></script>
<script type="text/javascript">
var LinkSelect = {
  init : function (ed) {
    var dom = ed.dom, n = ed.selection.getNode();
    if (n.nodeName == 'A') {
      //var href = dom.getAttrib(n, 'href');
      //var title = dom.getAttrib(n, 'title');
      //alert("found: " + href + "\n" + title);
    }

    <%--
    <c:choose>
      <c:when test="<%= hasText(link) %>">
        this.showWikiLinkPreview("<%= StringUtils.toHtmlValue(link) %>");
      </c:when>
      <c:otherwise>
        this.showWikiLinkPreview("<%= StringUtils.toHtmlValue(targetWiki.getSubject()) %>");
      </c:otherwise>
    </c:choose>
    --%>
  },

  insertAndClose : function() {
    var ed = tinyMCEPopup.editor, args = {}, el;
    var dom = ed.dom;
    tinyMCEPopup.restoreSelection();
		// Fixes crash in Safari
    if (tinymce.isWebKit)
      ed.getWin().focus();

     // Set the variables based on the tab
    var linkHref = '';

    // Determine if an internal or external link
    var subject = document.getElementById('wikilink').value;
    if (subject.indexOf("http://") == 0 ||
        subject.indexOf("https://") == 0 ||
        subject.indexOf("/") == 0 ||
        subject.indexOf("ftp://") == 0 ||
        subject.indexOf("mailto:") == 0) {
      linkHref = subject;
    } else {
      // URL reserved
      //      subject = subject.replace(/=/g, "_");
      //      subject = subject.replace(/;/g, "_");
      subject = subject.replace(/\//g, "_");
      subject = subject.replace(/#/g, "_");
      //      subject = subject.replace(/\?/g, "_");
      subject = escape(subject);
      // Conformity
      subject = subject.replace(/%20/g, "+");
      subject = subject.replace(/&apos;/gi, "'");
      subject = subject.replace(/%u2019/gi, "'");
      subject = subject.replace(/'/g, "%27");
      subject = subject.replace(/\"/g, "%22");
      linkHref = "${ctx}/show/<%= project.getUniqueId() %>/wiki/" + subject;
    }

    // Update the editor
    tinyMCEPopup.execCommand("mceBeginUndoLevel");
    el = ed.selection.getNode();

    if (el && el.nodeName == 'A') {
      dom.setAttrib(el, 'href', linkHref);
    } else {
      // TinyMCE CreateLink will not create links to images with block style
      var center = false;
      if (el && el.nodeName == 'IMG') {
        if (dom.getAttrib(el, 'style').indexOf('block') > -1) {
          center = true;
          dom.setAttrib(el, 'style', 'display:inline;');
        }
      }

      // Make the link
      var elm, elementArray, i;
      tinyMCEPopup.execCommand("CreateLink", false, "#mce_temp_url#", {skip_undo : 1});
      elementArray = tinymce.grep(dom.select("a"), function(n) {return dom.getAttrib(n, 'href') == '#mce_temp_url#';});
      for (i=0; i<elementArray.length; i++) {
        elm = elementArray[i];
        try {
          tinyMCEPopup.editor.selection.collapse(false);
        } catch (ex) {
          // Ignore
        }
        dom.setAttrib(elm, 'href', linkHref);
      }

      // Revert the centering
      if (center) {
        dom.setAttrib(el, 'style', 'display:block; margin: 0 auto;');
      }
    }
    tinyMCEPopup.execCommand("mceEndUndoLevel");
    tinyMCEPopup.close();
  }

  <%--
  showWikiLinkPreview : function(value) {

    var linkHref = "";
    // Determine if an internal or external link
    var subject = document.getElementById('wikilink').value;
    if (subject.indexOf("http://") == 0 || linkHref.indexOf("https://") == 0) {
      linkHref = subject;
    } else {
      subject = escape(subject);
      subject = subject.replace(/%20/g, "+");
      linkHref = "<%= RequestUtils.getAbsoluteServerUrl(request) %>/show/<%= project.getUniqueId() %>/wiki/" + subject;
    }

    var preview = '<a target="_blank" class="wikiLink<%= targetWiki.getId() == -1 ? " newWiki" : ""%>" href="' + linkHref + '">' + value + '</a>';
    changeDivContent('wikilinkpreview', preview);
  }
  --%>
};

tinyMCEPopup.onInit.add(LinkSelect.init, LinkSelect);
function onCancel() {
  tinyMCEPopup.close();
};

</script>
<div class="portletWrapper">
  <form onsubmit="LinkSelect.insertAndClose();return false;" action="#">
    <h1>Insert a Link</h1>
    <div class="tabs">
       <ul>
         <li id="wikilink_tab" class="current"><span><a href="javascript:mcTabs.displayTab('wikilink_tab','wikilink_panel');" onmousedown="return false;">Wiki Link</a></span></li>
         <%--
         <li id="weblink_tab" <ccp:evaluate if="<%= hasText(link) %>"> class="current"</ccp:evaluate>><span><a href="javascript:mcTabs.displayTab('weblink_tab','weblink_panel');" onmousedown="return false;">Web Link</a></span></li>
         <li id="search_tab"><span><a href="javascript:mcTabs.displayTab('search_tab','search_panel');" onmousedown="return false;">Search</a></span></li>
         --%>
      </ul>
    </div>
    <div class="panel_wrapper" style="height:365px">
      <%-- WIKI LINK --%>
      <div id="wikilink_panel" class="panel current">
        <fieldset>
          <legend>Create a Link</legend>
          <div class="wikiHeader">
            <label id="wikilinklabel" for="wikilink">Link to the following wiki, profile page, or external web site:</label>
          </div>
          <div class="wikiBody">
            <input name="wikilink" type="text" id="wikilink" size="50"
            <c:choose>
              <c:when test="<%= hasText(link) %>">
                value="<%= StringUtils.toHtmlValue(link) %>"
              </c:when>
              <c:otherwise>
                value="<%= StringUtils.toHtmlValue(targetWiki.getSubject()) %>"
              </c:otherwise>
            </c:choose>
            class="mceFocus" />
          </div>
          <%--
          <div class="wikiHeader">
            <label id="wikilinkaltlabel" for="wikilinkalt">Display the link with different text:</label>
          </div>
          <div class="wikiBody">
            <input id="wikilinkalt" name="wikilinkalt" type="text" size="50" value="<%= StringUtils.toHtmlValue(content) %>" onkeyup="LinkSelect.showWikiLinkPreview(this.value);" />
          </div>
          --%>
        </fieldset>
        <fieldset>
          <legend>Notes</legend>
          <div class="wikiHeader">
            <p>There are two kinds of links that can be created</p>
            <%--<ul>--%>
              <li>Links to external websites</li>
              <li>Links to other documents on this site, including wikis and other pages</li>
            <%--</ul>--%>
            <p>To link to external websites, be sure to use http:// or https:// at the beginning of the link.</p>
            <p>To link to documents on this site, paste the target URL or type the name of a Wiki Page.</p>
            <c:if test="<%= !hasText(link) %>">
              <p><strong>
                <ccp:evaluate if="<%= targetWiki.getId() > -1 %>">
                  A target wiki page exists for this link.
                </ccp:evaluate>
                <ccp:evaluate if="<%= targetWiki.getId() == -1 %>">
                  If you are linking to a wiki page, then the target wiki page doesn't
                  appear to exist yet, so the link
                  will have a reminder icon appear next to the link.  Once the target
                  page has content, the reminder icon will automatically disappear.
                </ccp:evaluate>
              </strong></p>
            </c:if>
          </div>
        </fieldset>
        <%--
        <fieldset>
          <legend>Preview of the link</legend>
            <div id="wikilinkpreview">
              <a target="_blank" class="wikiLink<%= targetWiki.getId() == -1 ? " newWiki" : ""%>" href="#"><%= StringUtils.toHtmlValue(content) %></a>
          </div>
        </fieldset>
        --%>
      </div>
      <%-- WEB LINK --%>
      <%--
      <div id="weblink_panel" class="panel">
        <fieldset>
          <legend>General</legend>
          <p>
            <label id="weblinklabel" for="weblink">Link to the following external web site url:</label><br />
            <input name="weblink" type="text" id="weblink" size="50" value="<%= StringUtils.toHtmlValue(link) %>" class="mceFocus url" onchange="LinkSelect.showWebLinkPreview(this.value);" /><br />
            (use the complete url, example: http://www.concursive.com)
          </p>
        </fieldset>
        <fieldset>
          <legend>Preview</legend>
          <div id="weblinkpreview">
            <a class="wikiLink external" href="#"><%= StringUtils.toHtmlValue(content) %></a>
          </div>
        </fieldset>
      </div>
      --%>
      <%-- SEARCH FOR A LINK --%>
      <%--
      <div id="search_panel" class="panel">
        <fieldset>
          <legend>Search</legend>
          <p>
            <label id="searchlinklabel" for="searchlink">Search content to link to:</label><br />
            <input name="searchlink" type="text" id="searchlink" size="50" value="<%= StringUtils.toHtmlValue(targetWiki.getSubject()) %>" class="mceFocus" />
            <input type="button" name="Search" value="Search" onclick="LinkSelect.performSearch()" />
          </p>
          <p>
            <label id="searchlinkaltlabel" for="searchlinkalt">Display the link with a different name:</label><br />
            <input id="searchlinkalt" name="searchlinkalt" type="text" size="50" value="<%= StringUtils.toHtmlValue(targetWiki.getSubject()) %>" />
          </p>
        </fieldset>
        <fieldset>
          <legend>Results</legend>
          <div id="searchlinkresults" style="height:175px;overflow-y:scroll;">
            <table border="0" cellpadding="4" cellspacing="0" width="100%">
              <tr class="row1">
                <td>
                  <input type="radio" id="result1" name="result" class="radio" onclick="LinkSelect.setSearchResult('result1')" />
                  <label id="result1label" for="result1">Search result 1</label><br />
                </td>
              </tr>
              <tr class="row2">
                <td>
                  <input type="radio" id="result2" name="result" class="radio" onclick="LinkSelect.setSearchResult('result2')" />
                  <label id="result2label" for="result2">Search result 2</label><br />
                </td>
              </tr>
            </table>
          </div>
        </fieldset>
        <fieldset>
          <legend>Preview</legend>
          <div id="searchlinkpreview">
            This is a placeholder for the preview.
          </div>
        </fieldset>
      </div>
      --%>
    </div>
    <div class="mceActionPanel">
      <div style="float: left">
        <input type="submit" id="insert" name="insert" value="{#insert}" />
      </div>
      <div style="float: right">
        <input type="button" id="cancel" name="cancel" value="{#cancel}" onclick="tinyMCEPopup.close();" />
      </div>
    </div>
  </form>
</div>