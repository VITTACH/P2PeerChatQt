import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.XmlListModel 2.0
import QtQuick 2.0

Rectangle {
    id: baseRect
    color: loader.mainBackgroundColor

    anchors.fill: parent
    anchors.topMargin: actionBar.height

    property int nWidth: 0

    ListView {
        id: basView
        width: parent.width
        spacing: facade.toPx(15)

        anchors {
            top: parent.top
            bottom: downRow.top
            bottomMargin: facade.toPx(15)
        }

        boundsBehavior: {
            contentY <= 0 ? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds;
        }

        model: ListModel {
            id: feedsModel
            ListElement {}
            ListElement {}
        }

        delegate: Column {
            x: facade.toPx(15)
            width: nWidth = Math.min(parent.width - facade.toPx(80), facade.toPx(800))

            function concatUriParams(data) {
                return typeof data == 'string' ? data : Object.keys(data).map(
                     function(key) {
                         return encodeURIComponent(key) + '=' + encodeURIComponent(data[key])
                     }
                 ).join('&')
            }

            function requestVideoLink(id, videoMeta, cache, size) {
                var request = new XMLHttpRequest()
                request.open('GET', "https://you-link.herokuapp.com/?url=https://www.youtube.com/watch?v=" + id)
                request.onreadystatechange = function() {
                    if (request.readyState == XMLHttpRequest.DONE && request.status == 200) {
                        var links = JSON.parse(request.responseText)
                        var obj = {
                            title: videoMeta.title,
                            pDesc: videoMeta.description,
                            image: videoMeta.thumbnails.default.url,
                            hdUrl: links[0].url,
                            pDate: Qt.formatDateTime(videoMeta.publishedAt, "dd.MM.yy hh:mm")
                        }

                        videoModel.append(obj)
                        cache.push(obj)

                        if (size === cache.length) {event_handler.saveSettings("videos", JSON.stringify(cache))}
                    }
                }

                request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
                request.send()
            }

            function youtubeRequest(url, data) {
                var params = concatUriParams(data)
                videoModel.clear()

                var request = new XMLHttpRequest()
                request.open('GET', url + "?" + params)
                request.onreadystatechange = function() {
                    if (request.readyState == XMLHttpRequest.DONE) {
                        if (request.status == 200) {
                            var cacheVideo = []
                            var items = JSON.parse(request.responseText).items
                            var size = items.length - 1
                            for (var i = 0; i < items.length; i++) {
                                var videoId = typeof items[i].id == "string" ? items[i].id : items[i].id.videoId
                                requestVideoLink(videoId, items[i].snippet, cacheVideo, size)
                            }
                        } else loadCachedVideos()
                    }
                }

                request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
                request.send()
            }

            function loadCachedVideos() {
                var recentVideos = event_handler.loadValue("videos")
                if (recentVideos != "") {
                    var cache = JSON.parse(recentVideos)
                    for (var i = 0; i < cache.length; i++) {
                        videoModel.append({
                            title: cache[i].title,
                            pDesc: cache[i].pDesc,
                            hdUrl: cache[i].hdUrl,
                            pDate: cache[i].pDate,
                            image: cache[i].image
                        });
                    }
                }
            }

            function searchingVideo(metadata) {
                var params = {"part": "snippet", "q": metadata, "maxResults": 10, "key": loader.youtube_api_key}
                youtubeRequest(loader.youtube_base_url + "search", params)
            }

            Connections {
                target: actionBar
                onEditUrlChanged: searchingVideo(actionBar.editUrl)
            }

            Item {
                visible: index == 0
                property int countCard: 4

                width: parent.width
                height: {
                    var cardHeight = facade.toPx(210);
                    var count = Math.floor((baseRect.height - (feedsModel.count -1)*basView.spacing)/cardHeight)
                    if (count < 4) count = 4
                    countCard = count
                    if (event_handler.currentOSys() > 0 && Screen.orientation === Qt.LandscapeOrientation) {
                        countCard = 2 * countCard
                    }
                    return countCard * cardHeight -feedView.spacing
                }

                Component.onCompleted: {
                    var params = {"part": "snippet", "chart": "mostPopular", "regionCode": "RU", "maxResults": 10, "key": loader.youtube_api_key}
                    youtubeRequest(loader.youtube_base_url + "videos", params)
                }

                ListView {
                    id: feedView
                    clip: true
                    width: parent.width
                    height: parent.height

                    boundsBehavior: (contentY < 1)? Flickable.StopAtBounds: Flickable.DragAndOvershootBounds;

                    model: ListModel {id: videoModel}

                    delegate: Button {
                        width: parent.width
                        height: Math.max(facade.toPx(280), description.height)
                        Component.onCompleted: background.color = loader.newsBackgroundColor

                        Rectangle {
                            id: bag;
                            clip: true
                            smooth: true
                            x: facade.toPx(10)
                            y: facade.toPx(20)
                            width: facade.toPx(200)
                            height:width
                            Image {
                                source: typeof image!="undefined"?image.replace("ps","p"):""
                                anchors.centerIn: parent
                                height:sourceSize.width > sourceSize.height? parent.height: sourceSize.height*(parent.width / sourceSize.width)
                                width: sourceSize.width > sourceSize.height? sourceSize.width*(parent.height / sourceSize.height): parent.width
                            }
                        }

                        Column {
                            id: description
                            y: facade.toPx(20)
                            anchors {
                                left: bag.right
                                right: parent.right
                                leftMargin: facade.toPx(20)
                            }

                            Text {
                                text: title
                                color: loader.newsHeadColor
                                elide: Text.ElideRight
                                width: {parent.width - facade.toPx(30);}
                                font.bold: true
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(22);
                            }

                            Text {
                                text: pDate
                                color: loader.newsDateColor
                                lineHeight: 1.4
                                width: {parent.width - facade.toPx(30);}
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(15);
                            }

                            Text {
                                text: pDesc
                                color: loader.newsDescColor
                                maximumLineCount: 4
                                width: {parent.width - facade.toPx(30);}
                                wrapMode: Text.Wrap
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(20);
                            }
                        }

                        onClicked: {
                            if (chatScreen.position > 0) return;
                            loader.urlLink = videoModel.get(index).hdUrl
                            actionBar.page = 1
                        }
                    }
                }
            }

            Rectangle {
                clip: true
                visible: index == 1
                width: parent.width
                height: facade.toPx(160)
                radius: facade.toPx(10);

                color: loader.pageBackgroundColor

                ListView {
                    width: parent.width - facade.toPx(50)
                    height: parent.height - facade.toPx(16)
                    spacing: (width - pages.count * facade.toPx(144)) / (pages.count - 1)
                    orientation: Qt.Horizontal
                    anchors.centerIn: {parent}

                    model:ListModel {
                        id: pages
                        ListElement {image: "/ui/buttons/feed/mus.png";}
                        ListElement {image: "/ui/buttons/feed/img.png";}
                        ListElement {image: "/ui/buttons/feed/vide.png"}
                        ListElement {image: "/ui/buttons/feed/play.png"}
                    }

                    delegate: Item {
                        width: img.width
                        height: img.height

                        DropShadow {
                            samples: 18
                            source: img
                            color: "#50000000"
                            radius: 12
                            anchors.fill: img;
                        }
                        Image {
                            id: img
                            width: facade.toPx(sourceSize.width / 3.55)
                            height: facade.toPx(sourceSize.height/ 3.55)
                            anchors.centerIn: parent
                            source: image
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: downRow
        width: parent.width
        height: facade.toPx(80);
        anchors.bottom: parent.bottom
        color: loader.menu9Color

        Item {
            clip: true
            width: nWidth
            height:parent.height
            x: facade.toPx(10)

            ListView {
                id: bottomNav;
                property var buttonWidth: facade.toPx(140)
                anchors.horizontalCenter: parent.horizontalCenter
                orientation: Qt.Horizontal
                spacing: facade.toPx(50)
                height: parent.height
                width: (buttonWidth+spacing)*model.count-spacing;

                model: ListModel {
                    ListElement {
                        message: "Контакты"
                    }
                    ListElement {
                        message: "Партнеры"
                    }
                    ListElement {
                        message: "Поделись"
                    }
                    ListElement {
                        message: "CoinRoad"
                    }
                }

                delegate: Item {
                    width: bottomNav.buttonWidth
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: message
                        anchors.centerIn: parent
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(16);
                    }
                }
            }
        }
    }
}
