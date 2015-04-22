import 'dart:html';
import 'dart:async';
import 'dart:convert';

void main() {
  // Form input
  InputElement formName     = querySelector("#form-input-name");
  TextAreaElement formMess  = querySelector("#form-input-message");

  // Form actions
  ButtonElement formSubmit    = querySelector("#form-submit");
  ButtonElement formClearAll  = querySelector("#form-clear-all");

  // Response
  DivElement respWrap = querySelector("#response-wrapper");
  DivElement formResp = querySelector("#response");

  // Init service (9090 for during development locally,
  // otherwise use standard port 80 for production)
  Uri uri = Uri.parse(window.location.href);
  var port = uri.port != 8080 ? 80 : 9090;
  String baseUrl = 'http://${uri.host}:${port}';

  // Load the list of previously added posts
  getPosts(baseUrl).then((response) => addPostsToDOM(formResp, response));

  // Handle form submit
  formSubmit.onClick.listen((e) {
    // Prevent default form actions
    e.preventDefault();

    // Send request to the server
    HttpRequest.request("${baseUrl}/posts/add", method: "POST",
      requestHeaders: {"Content-Type": "application/json"},
      sendData: JSON.encode({"name": formName.value, "message": formMess.value}))
    .then((response) {
      print(response.responseText);

      // Reload list of posts
      getPosts(baseUrl).then((response) => addPostsToDOM(formResp, response));
    }).catchError((e) {
      print("Unable to add post");
    });
  });

  // Remove all posts
  formClearAll.onClick.listen((e) {
    // Prevent default form actions
    e.preventDefault();

    // Clear list of posts
    formResp.children.clear();

    // Delete posts from the database
    deletePosts(baseUrl).then((response) {
      print(response);
      getPosts(baseUrl).then((response) => addPostsToDOM(formResp, response));
    });
  });
}

// Add a post to the dom
void addPostsToDOM(DivElement posts, String response) {
  if(response != "") {
    List responseList = JSON.decode(response);
    posts.children.clear();
    responseList.forEach((Map post) {

      // Create a new dom element for each post
      DivElement postDiv = new DivElement()
        ..classes = ["content-offset", "well"]
        ..children.addAll(
        [
          new ParagraphElement()
            ..classes.add("text-bold")
            ..text = "${post["name"]}",
          new ParagraphElement()
            ..text = "${post["message"]}"
        ]
      );

      // Append the new element to parent div
      posts.append(postDiv);
    });
  }
}

// Get all posts
Future<String> getPosts(String baseUrl) {
  var c = new Completer();

  // Send request to the server
  HttpRequest.request("${baseUrl}/posts/list", method: "GET").then((response) {
    c.complete(response.responseText);
  }).catchError((e) {
    print("Unable to get posts");
    c.complete("");
  });

  return c.future;
}

// Delete all posts
Future deletePosts(String baseUrl) {
  var c = new Completer();

  // Send request to the server
  HttpRequest.request("${baseUrl}/posts/delete", method: "DELETE").then((response) {
    c.complete(response.responseText);
  }).catchError((e) {
    print("Unable to delete posts");
    c.complete("");
  });

  return c.future;
}

