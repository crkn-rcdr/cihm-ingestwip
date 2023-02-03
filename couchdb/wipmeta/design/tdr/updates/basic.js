module.exports = function (doc, req) {
  var updatedoc = {};
  var nowdate = new Date();
  // Javascript toISOString() includes parts of a second, which we strip.
  var nowdates = nowdate.toISOString().replace(/\..*Z/, "Z");
  var updated = false;

  // Note that form data won't work for the values which aren't simple strings
  if (req.form && Object.keys(req.form).length > 0) {
    updatedoc = req.form;
  } else {
    try {
      updatedoc = JSON.parse(req.body);
    } catch (ignore) {
      return [
        null,
        JSON.stringify({ return: "could not parse body: " + req.body }) + "\n",
      ];
    }
  }
  if (!doc) {
    if ("id" in req && req["id"]) {
      if ("nocreate" in updatedoc) {
        return [null, '{"return": "no create"}\n'];
      } else {
        // create new document
        doc = {};
        doc["_id"] = req["id"];
        doc["created"] = nowdates;
        updated = true;
      }
    } else {
      // change nothing in database
      return [null, '{"return": "Missing ID"}\n'];
    }
  }

  // Generalized process request related fields
  if ("processreq" in updatedoc) {
    function addRequest(processReq) {
      if (!("date" in processReq)) {
        processReq.date = nowdates;
      }
      doc.processReq.push(processReq);
    }
    if (!"processReq" in doc || !Array.isArray(doc.processReq)) {
      doc.processReq = [];
    }
    var processReqData = JSON.parse(updatedoc.processreq);
    if (Array.isArray(processReqData)) {
      processReqData.forEach(addRequest);
    } else {
      addRequest(processReqData);
    }
    updated = true;
  }
  if ("processing" in updatedoc) {
    var ph = JSON.parse(updatedoc.processing);
    if (!("date" in ph)) {
      ph.date = nowdates;
    }
    if (
      !"processReq" in doc ||
      !Array.isArray(doc.processReq) ||
      doc.processReq.length === 0
    ) {
      return [null, '{"return": "no processReq"}\n'];
    }
    if (!("reqdate" in ph) || ph.reqdate !== doc.processReq[0].date) {
      return [null, '{"return": "No matching request date"}\n'];
    }
    if ("request" in ph) {
      var pr = doc.processReq[0].request;
      if (ph.request === "mallet" && (pr === "buildsip" || pr === "manipmd")) {
        ph.request = pr;
      }
    }
    if (!("request" in ph) || ph.request !== doc.processReq[0].request) {
      return [null, '{"return": "No matching request type"}\n'];
    }
    if ("processhost" in doc.processReq[0]) {
      if (doc.processReq[0].processhost === ph.host) {
        return [null, '{"return": "already set"}\n'];
      } else {
        return [null, '{"return": "other host"}\n'];
      }
    } else {
      doc.processReq[0].processhost = ph.host;
      doc.processReq[0].processdate = ph.date;
      updated = true;
    }
  }
  if ("processed" in updatedoc) {
    var processed = JSON.parse(updatedoc["processed"]);
    if (!("date" in processed)) {
      processed.date = nowdates;
    }
    if (!"processHistory" in doc || !Array.isArray(doc.processHistory)) {
      doc.processHistory = [];
    }
    if (
      !"processReq" in doc ||
      !Array.isArray(doc.processReq) ||
      doc.processReq.length === 0
    ) {
      return [null, '{"return": "no processReq"}\n'];
    }
    if (
      !("reqdate" in processed) ||
      processed.reqdate !== doc.processReq[0].date
    ) {
      return [null, '{"return": "No matching request date"}\n'];
    }
    if ("request" in processed) {
      var pr = doc.processReq[0].request;
      if (
        processed.request === "mallet" &&
        (pr === "buildsip" || pr === "manipmd")
      ) {
        processed.request = pr;
      }
    }
    if (
      !("request" in processed) ||
      processed.request !== doc.processReq[0].request
    ) {
      return [null, '{"return": "No matching request type"}\n'];
    }
    if (processed.status) {
      processed.req = [doc.processReq.shift()];
    } else {
      processed.req = doc.processReq;
      delete doc.processReq;

      // If failure wasn't move,
      // and there are files on filesystem, then do a move
      if (
        processed.request !== "move" &&
        "filesystem" in doc &&
        "identifier" in doc.filesystem &&
        "stage" in doc.filesystem
      ) {
        doc.processReq = [
          {
            request: "move",
            date: nowdates,
            stage: "Rejected",
          },
        ];
      }
    }
    // Don't add successful moves to History
    if (processed.request !== "move" || !processed.status) {
      if (
        doc.processHistory.length > 0 &&
        doc.processHistory[0].request === "silence"
      ) {
        doc.processHistory.shift();
      }
      doc.processHistory.unshift(processed);
    }
    updated = true;
  }
  if ("silence" in updatedoc) {
    if (
      Array.isArray(doc.processHistory) &&
      "status" in doc.processHistory[0] &&
      !doc.processHistory[0].status
    ) {
      doc.processHistory.unshift({
        request: "silence",
        date: nowdates,
        status: true,
      });
      updated = true;
    }
  }
  // Manipulating Label (METS fragment)
  if ("label" in updatedoc) {
    doc.label = updatedoc.label;
    updated = true;
  }

  // Repository related fields
  if ("repos" in updatedoc) {
    // This parameter sent as JSON encoded string
    var repos = JSON.parse(updatedoc["repos"]);

    // Equality is same membership, even if different order
    function hasSameMembers(repo1, repo2) {
      if (!repo1 || !repo2 || repo1.length != repo2.length) {
        return false;
      }
      // TODO: cheating for now - treat same if length same
      return true;
    }
    if (!("reposManifestDate" in doc) || !hasSameMembers(doc["repos"], repos)) {
      doc["repos"] = repos;
      doc["reposManifestDate"] = updatedoc["manifestdate"];
      updated = true;
    }
  }
  if ("METS" in updatedoc) {
    // This parameter sent as JSON encoded string
    doc["METS"] = JSON.parse(updatedoc["METS"]);
    doc["METSManifestDate"] = updatedoc["manifestdate"];
    doc["METSDate"] = nowdates;
    updated = true;
  }
  var retval = {};
  if ("reposManifestDate" in doc) {
    retval["METSmatch"] =
      "METSManifestDate" in doc &&
      doc.reposManifestDate === doc.METSManifestDate;
  }
  if (updated) {
    doc["updated"] = nowdates;
    retval["return"] = "update";
    return [doc, JSON.stringify(retval) + "\n"];
  } else {
    retval["return"] = "no update";
    return [null, JSON.stringify(retval) + "\n"];
  }
};
