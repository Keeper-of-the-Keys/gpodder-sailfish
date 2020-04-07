import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    Image {
        id: episodeArtArea
        visible: episode_art || cover_art ? true : false

        anchors {
            left: parent.left
            right: parent.right
        }
        height: episode_art ? parent.height * 0.9 : parent.height
        width: episode_art ? parent.width * 0.9 : parent.width

        source: episode_art ? episode_art : cover_art
    }
    Image {
        id: podcastArtArea
        visible: episode_art && cover_art ? true : false

        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        height: parent.height * 0.4
        width: parent.width * 0.4
        source: cover_art
    }
    Rectangle {
        anchors.fill: parent
        visible: !cover_art && !episode_art ? true : false
        color: Theme.rgba(Theme.highlightColor, 0.5)

        clip: true

        Label {
            anchors.centerIn: parent

            font.pixelSize: parent.height * 0.8
            text: episodesPage.title[0]
            color: Theme.highlightColor
        }
    }
}
