/* === This file is part of Calamares - <http://github.com/calamares> === */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function nextSlide() { presentation.goToNextSlide(); }

    Timer {
        id: advanceTimer
        interval: 7500
        running: true
        repeat: true
        onTriggered: nextSlide()
    }

    // Sfondo globale - Pure Minimalist Black to match Cashevide Sidebar
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        z: -1
    }

    // --- SLIDE 1 ---
    Slide {
        Image { 
            anchors.fill: parent 
            source: "1-reproductive-system.png" 
            fillMode: Image.PreserveAspectCrop
        }
    }

    // --- SLIDE 2 ---
    Slide {
        Image { 
            anchors.fill: parent 
            source: "2-start-reproduction.png" 
            fillMode: Image.PreserveAspectCrop
        }
    }

    // --- SLIDE 3 ---
    Slide {
        Image { 
            anchors.fill: parent 
            source: "3-its-your-system.png" 
            fillMode: Image.PreserveAspectCrop
        }
    }

    // --- SLIDE 4 ---
    Slide {
        Image { 
            anchors.fill: parent 
            source: "4-eggs-presentation.png" 
            fillMode: Image.PreserveAspectCrop
        }
    }

    // --- SLIDE 5 ---
    Slide {
        Image { 
            anchors.fill: parent 
            source: "5-wait-hatching.png" 
            fillMode: Image.PreserveAspectCrop
        }
    }

    // --- SLIDE 6 ---
    Slide {
        Image { 
            anchors.fill: parent 
            source: "6-follow-penguins.png" 
            fillMode: Image.PreserveAspectCrop
        }
    }

    // --- SLIDE 7 ---
    Slide {
        Image { 
            anchors.fill: parent 
            source: "7-created-by.png" 
            fillMode: Image.PreserveAspectCrop
        }
    }

    function onActivate() { presentation.currentSlide = 0; }
}
