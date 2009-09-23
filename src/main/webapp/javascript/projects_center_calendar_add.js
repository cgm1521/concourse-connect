/* * ConcourseConnect * Copyright 2009 Concursive Corporation * http://www.concursive.com * * This file is part of ConcourseConnect, an open source social business * software and community platform. * * Concursive ConcourseConnect is free software: you can redistribute it and/or * modify it under the terms of the GNU Affero General Public License as published * by the Free Software Foundation, version 3 of the License. * * Under the terms of the GNU Affero General Public License you must release the * complete source code for any application that uses any part of ConcourseConnect * (system header files and libraries used by the operating system are excluded). * These terms must be included in any work that has ConcourseConnect components. * If you are developing and distributing open source applications under the * GNU Affero General Public License, then you are free to use ConcourseConnect * under the GNU Affero General Public License. * * If you are deploying a web site in which users interact with any portion of * ConcourseConnect over a network, the complete source code changes must be made * available.  For example, include a link to the source archive directly from * your web site. * * For OEMs, ISVs, SIs and VARs who distribute ConcourseConnect with their * products, and do not license and distribute their source code under the GNU * Affero General Public License, Concursive provides a flexible commercial * license. * * To anyone in doubt, we recommend the commercial license. Our commercial license * is competitively priced and will eliminate any confusion about how * ConcourseConnect can be used and distributed. * * ConcourseConnect is distributed in the hope that it will be useful, but WITHOUT * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS * FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more * details. * * You should have received a copy of the GNU Affero General Public License * along with ConcourseConnect.  If not, see <http://www.gnu.org/licenses/>. * * Attribution Notice: ConcourseConnect is an Original Work of software created * by Concursive Corporation */function checkFormEventMeetingAdd(form) {  var formTest = true;  var messageText = "";  //Check required fields  if (form.title.value == "") {    messageText += "- Title is a required field\r\n";    formTest = false;  }  if (form.startDate.value == "") {    messageText += "- Start Date is a required field\r\n";    formTest = false;  }  if (form.endDate.value == "") {    messageText += "- End Date is a required field\r\n";    formTest = false;  }  var isEmpty = false;  form.meetingInvitees.value = form.meetingInvitees.value.trim();  if (form.meetingInvitees.value == "") {    isEmpty = true;  }  if (!formTest) {    messageText = "The form could not be submitted.          \r\nPlease verify the following items:\r\n\r\n" + messageText;    alert(messageText);    return false;  } else {    return true;  }}function addMember(profile, name) {  var field = document.inputForm.meetingInvitees;  field.value = field.value.trim();  profile = "(" + profile + ")";  //check if already added  if (field.value.search(profile) > -1) {    alert("The member is present in your invitee list.");    return;  }  // append a space if the list ends with a comma and if list is not empty  if ((field.value.lastIndexOf(",") + 1 == field.value.length) && (field.value != '')) {    field.value += " ";  } else {    // append a comma if the list is not empty    if (field.value != '')      field.value += ", ";  }  field.value += name + " " + profile;  field.focus();  var inputEl = document.getElementById("meetingInvitees");  inputEl.setSelectionRange(field.value.length, field.value.length);}function calendarTrigger(formName, fieldName, fieldValue, isLangEN) {  // If the user is adjusting the startDate, and the endDate is earlier,  // set the endDate to startDate  if (fieldName == "startDate" && isLangEN) {    if (Date.parse(document.inputForm.startDate.value) > Date.parse(document.inputForm.endDate.value)) {      document.inputForm.endDate.value = document.inputForm.startDate.value;    }  }}function checkFormEventMeetingConfirm(form) {  var formTest = true;  var messageText = "";  //Check required fields  if (form.emailAddress != null) {    for (i = 0; i < form.emailAddress.length; i++) {      form.emailAddress[i].value = form.emailAddress[i].value.trim();      if (form.emailAddress[i].value != "" && !checkEmail(form.emailAddress[i].value)) {        messageText += "- Email address is not valid\r\n";        formTest = false;        break;      }    }  }  form.dimdimUrl.value = form.dimdimUrl.value.trim();  if (form.dimdimUrl.value == "") {    messageText += "- Dimdim server URL is a required field\r\n";    formTest = false;  }  form.dimdimUsername.value = form.dimdimUsername.value.trim();  if (form.dimdimUsername.value == "") {    messageText += "- Dimdim username is a required field\r\n";    formTest = false;  }  form.dimdimPassword.value = form.dimdimPassword.value.trim();  if (form.dimdimPassword.value == "") {    messageText += "- Dimdim password is a required field\r\n";    formTest = false;  }  if (!formTest) {    messageText = "The form could not be submitted.          \r\nPlease verify the following items:\r\n\r\n" + messageText;    alert(messageText);    return false;  } else {    return true;  }}