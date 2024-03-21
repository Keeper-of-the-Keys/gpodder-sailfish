
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, Thomas Perl <m@thp.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

import 'common'
import 'common/util.js' as Util

Page {
    id: playerPage

    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        contentWidth: column.width
        contentHeight: column.height + column.spacing

        PullDownMenu {
            PlayerChaptersItem {
                model: player.episode_chapters
            }

            MenuItem {
                text: player.sleepTimerRunning ? qsTr("Stop sleep timer") : qsTr("Sleep timer")
                onClicked: {
                    if (player.sleepTimerRunning) {
                        player.stopSleepTimer();
                    } else {
                        pageStack.push('SleepTimerDialog.qml', { player: player });
                    }
                }
            }

            MenuItem {
                text: qsTr("Clear play queue")
                enabled: playQueueRepeater.count > 0
                onClicked: player.clearQueue()
            }
        }

        Flow {
            id: pageFlow
            width: parent.width

            Column {
                id: artColumn
                width: isPortrait ? parent.width : parent.width * 0.55

                VideoOutput {
                    id: videoOutputPP
                    source: player
                    visible: player.hasVideo && player.status >= MediaPlayer.Loaded && player.status <= MediaPlayer.EndOfMedia
                    width: parent.width

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent

                        /*onDoubleClicked: {
                                             if(videoOutputPP.state == "videoFullScreen") {
                                                 videoOutputPP.state = "videoSmall"
                                             } else {
                                                 videoOutputPP.state = "videoFullScreen"
                                             }
                                         }*/
                        onClicked: {
                            if (player.isPlaying) {
                                player.pause();
                            } else {
                                player.play();
                            }
                        }
                    }
                    /*State {
                        name: "videoFullScreen"
                        ParentChange {
                            target: videoOutputPP
                            parent: column
                        }
                    }
                    State {
                        name: "videoSmall"
                        ParentChange {
                            target: videoOutputPP
                            parent: playQueueRepeater
                        }
                    }*/
                }

                Image {
                    id: art

                    width: parent.width
                    fillMode: Image.PreserveAspectFit

                    visible: !player.hasVideo && (player.episode_art !== '' || player.podcast_cover !== '')
                    asynchronous: true

                    source: player.episode_art !== '' ? player.episode_art : player.cover_art
                }
            }
            Column {
                width: isPortrait ? parent.width : parent.width * 0.45

                SectionHeader {
                    text: qsTr("Now playing")
                    visible: player.episode !== 0
                }


                Item {
                    height: Theme.paddingSmall
                    width: parent.width
                }

                Row {
                    id: playing_info_block
                    width: parent.width

                    Image {
                        id: podcast_cover
                        height: playerPage.isPortrait ? parent.width * 0.2 : parent.width * 0.1
                        width: this.height
                        visible: (player.cover_art !== '' && player.episode_art !== '')

                        source: player.cover_art
                    }

                    Item {
                        width: Theme.paddingSmall
                        height: parent.height
                    }

                    Column {
                        Label {
                            id: podcast_title
                            anchors {
                                margins: Theme.paddingLarge
                            }

                            truncationMode: TruncationMode.Fade
                            horizontalAlignment: Text.AlignHLeft
                            text: player.podcast_title
                            color: Theme.secondaryHighlightColor
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Item {
                            width: parent.width
                            height: Theme.paddingSmall
                        }

                        Label {
                            id: episode_title
                            anchors {
                                margins: Theme.paddingLarge
                            }

                            truncationMode: TruncationMode.Fade
                            horizontalAlignment: Text.AlignHLeft
                            text: player.episode_title
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Item {
                            width: parent.width
                            height: Theme.paddingSmall
                        }
                    }
                }

                Label {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    font.pixelSize: Theme.fontSizeLarge
                    text: Util.formatPosition(positionSlider.value/1000, player.duration/1000)
                    color: positionSlider.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingLarge
                    }

                    visible: player.sleepTimerRunning

                    truncationMode: TruncationMode.Fade
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Sleep timer: ") + Util.formatDuration(player.sleepTimerRemaining)
                    color: Theme.rgba(Theme.highlightColor, 0.7)
                    font.pixelSize: Theme.fontSizeExtraSmall
                }

                Connections {
                    target: player
                    onPositionChanged: {
                        if (!positionSlider.down) {
                            positionSlider.value = player.position;
                        }
                    }
                }

                Slider {
                    id: positionSlider
                    width: parent.width

                    value: player.position
                    minimumValue: 0
                    maximumValue: player.duration
                    handleVisible: false
                    onDownChanged: {
                        if (!down) {
                            player.seekAndSync(sliderValue)
                        }
                    }
                }

                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        margins: Theme.paddingMedium
                    }

                    height: Theme.itemSizeLarge
                    spacing: Theme.paddingMedium

                    GpodderIconMenuItem {
                        text: qsTr("- 1 min")
                        icon.source: 'image://theme/icon-m-previous'

                        GPodderAutoFire {
                            running: parent.down
                            onFired: player.seekAndSync(player.position - 1000 * 60)
                        }
                    }

                    GpodderIconMenuItem {
                        text: qsTr("- 10 sec")
                        icon.source: 'image://theme/icon-m-previous'
                        GPodderAutoFire {
                            running: parent.down
                            onFired: player.seekAndSync(player.position - 1000 * 10)
                        }
                    }

                    GpodderIconMenuItem {
                        text: player.isPlaying ? qsTr("Pause") : qsTr("Play")
                        onClicked: {
                            if (player.isPlaying) {
                                player.pause();
                            } else {
                                player.play();
                            }
                        }
                        icon.source: player.isPlaying ? 'image://theme/icon-m-pause' : 'image://theme/icon-m-play'
                    }

                    GpodderIconMenuItem {
                        text: qsTr("+ 10 sec")
                        icon.source: 'image://theme/icon-m-next'
                        GPodderAutoFire {
                            running: parent.down
                            onFired: player.seekAndSync(player.position + 1000 * 10)
                        }
                    }

                    GpodderIconMenuItem {
                        text: qsTr("+ 1 min")
                        icon.source: 'image://theme/icon-m-next'
                        GPodderAutoFire {
                            running: parent.down
                            onFired: player.seekAndSync(player.position + 1000 * 60)
                        }
                    }
                }
                ListItem {
                    anchors.horizontalCenter: parent.horizontalCenter
                    Label {
                        id: playbackspeedTitle
                        text: qsTr("Playback speed: ")

                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.highlightColor

                        anchors {
                            right: parent.horizontalCenter
                            margins: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                        }

                        wrapMode: Text.WordWrap
                    }
                    Label {
                        id: sectionField
                        text: player.playbackRate

                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.primaryColor

                        anchors {
                            left: parent.horizontalCenter
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    onClicked: openMenu()

                    menu: ContextMenu {
                        container: sectionField
                        MenuItem {
                            Slider {
                                id: speedSlider
                                width: parent.width

                                value: player.playbackRate
                                valueText: Math.round(value * 100) / 100
                                minimumValue: 0.5
                                maximumValue: 3.0
                                stepSize: 0.25
                                onDownChanged: {
                                    if (!down) {
                                        player.playbackRate = sliderValue
                                    }
                                }
                            }
                        }
                    }
                }

                SectionHeader {
                    text: qsTr("Queue")
                    visible: playQueueRepeater.count > 0
                }

                Repeater {
                    id: playQueueRepeater
                    model: player.queue
                    property Item contextMenu

                    property var queueConnections: Connections {
                        target: player

                        onQueueUpdated: {
                            playQueueRepeater.model = player.queue;
                        }
                    }

                    ListItem {
                        id: playQueueListItem

                        width: parent.width

                        menu: ContextMenu {
                            MenuItem {
                                text: qsTr("Remove from queue")
                                onClicked: player.removeQueueIndex(index);
                            }
                        }

                        Label {
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: Theme.paddingMedium
                                verticalCenter: parent.verticalCenter
                            }

                            text: modelData.title
                            truncationMode: TruncationMode.Fade
                        }

                        onClicked: {
                            player.jumpToQueueIndex(index);
                        }
                    }
                }

            }
        }
    }
}
