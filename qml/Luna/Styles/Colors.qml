pragma Singleton

import QtQuick 2.15

QtObject {
	id: _root
	readonly property color primaryColor: "#017AFF"
	readonly property color primaryColorHover: "#16A8FF"
	readonly property color primaryColorPressed: "#0269D8"
	readonly property color primaryColorLighter: "#48B5F9"
	readonly property color primaryColorDisabled: "#374861"

	readonly property color secondaryColor: "#455A7A"
	readonly property color secondaryColorHover: "#60789C"
	readonly property color secondaryColorPressed: "#384C6A"
	readonly property color secondaryColorLighter: "#8397B4"
	readonly property color secondaryColorDisabled: "#374861"

	readonly property color windowColor: "#293547"
	readonly property color windowBorderColor: "#0C1119"
	readonly property color windowColorDarker: "#1A2435"
	readonly property color windowColorDisabled: "#202B3C"

	readonly property color tooltipColor: "#0C1119"
	readonly property color tooltipShadowColor: "#c0000000"

	readonly property color bodyTextColor: "#ffffff"
	readonly property color bodyTextColorDisabled: secondaryColorHover

	readonly property color captionTextColor: secondaryColor
	readonly property color captionTextColorDisabled: secondaryColorDisabled

	readonly property color shadowColor: "#cf000000"
	readonly property color shadowColorLighter: "#50000000"

	readonly property color sliderHandleColor: "#D2E2F7"
	readonly property color sliderHandleColorHover: "#ffffff"
	readonly property color sliderHandleColorPressed: "#ffffff"

	readonly property color menuColor: colorWithAlpha(tooltipColor, 0.9)
	readonly property color menuBorderColor: secondaryColorPressed

	readonly property color rowColorOdd: windowColorDarker
	readonly property color rowColorEven: windowColorDisabled

	readonly property color scrollBarGroove: "#00000000"
	readonly property color scrollBarGroovePressed: "#55000000"
	readonly property color scrollBarGrooveHovered: "#44000000"
	readonly property color scrollBarGrooveDisabled: "#00000000"

	// Keeps the R, G and B channels but sets the A channel as alphaValue.
	// @param alphaValue Alpha between 0.0 and 1.0
	function colorWithAlpha(color, alphaValue) {
		return color ? Qt.rgba(color.r, color.g, color.b, alphaValue) : "black"
	}

	function getPrimary(isHovered, isDown, isEnabled) {
		if (!isEnabled)
			return primaryColorDisabled
		else if (isDown)
			return primaryColorPressed
		else if (isHovered)
			return primaryColorHover
		else
			return primaryColor
	}

	function getPrimaryHighlight(isHovered, isDown, isEnabled) {
		if (!isEnabled)
			return primaryColorDisabled
		else if (isDown)
			return primaryColorPressed
		else if (isHovered)
			return primaryColorLighter
		else
			return primaryColorHover
	}

	function getSecondary(isHovered, isDown, isEnabled) {
		if (!isEnabled)
			return secondaryColorDisabled
		else if (isDown)
			return secondaryColorPressed
		else if (isHovered)
			return secondaryColorHover
		else
			return secondaryColor
	}

	function getSecondaryHighlight(isHovered, isDown, isEnabled) {
		if (!isEnabled)
			return secondaryColorDisabled
		else if (isDown)
			return secondaryColorPressed
		else if (isHovered)
			return secondaryColorLighter
		else
			return secondaryColorHover
	}

	function getControlText(isEnabled) {
		return isEnabled ? bodyTextColor : bodyTextColorDisabled
	}

	function getControlCaption(isEnabled) {
		return isEnabled ? secondaryColorLighter : secondaryColor
	}

	function getControlPlaceholder(isEnabled) {
		return isEnabled ? secondaryColor : secondaryColorDisabled
	}

	function getControlBackground(isEnabled) {
		return isEnabled ? windowColorDarker : windowColorDisabled
	}

	function getSliderHandle(isHovered, isDown, isEnabled, isChecked) {
		if (isChecked) {
			if (!isEnabled) {
				return secondaryColor
			} else if (isDown) {
				return sliderHandleColorPressed
			} else if (isHovered) {
				return sliderHandleColorHover
			} else {
				return sliderHandleColor
			}
		} else {
			if (!isEnabled) {
				return secondaryColorDisabled
			} else if (isDown) {
				return secondaryColorHover
			} else if (isHovered) {
				return secondaryColorHover
			} else {
				return secondaryColor
			}
		}
	}

	function getSliderGroove(isEnabled, isChecked) {
		if (isChecked) {
			return isEnabled ? primaryColor : primaryColorDisabled
		} else {
			return isEnabled ? windowColorDarker : windowColorDisabled
		}
	}

	function getMenuItem(isHovered, isDown) {
		if (isDown) {
			return primaryColorPressed
		} else if (isHovered) {
			return primaryColor
		} else {
			return colorWithAlpha(primaryColor, 0)
		}
	}

	function getListItem(isCurrent, isHovered, isDown) {
		if (isDown) {
			return primaryColorPressed
		} else if (isCurrent) {
			return primaryColor
		} else if (isHovered) {
			return primaryColorHover
		} else {
			return colorWithAlpha(primaryColor, 0)
		}
	}

	function getScrollBarHandle(isHovered, isDown, isEnabled) {
		if (!isEnabled) return secondaryColorDisabled
		if (isDown) return secondaryColorPressed
		if (isHovered) return secondaryColorHover
		return secondaryColor
	}

	function getScrollBarGroove(isHovered, isDown, isEnabled) {
		if (!isEnabled) return scrollBarGrooveDisabled
		if (isDown) return scrollBarGroovePressed
		if (isHovered) return scrollBarGrooveHovered
		return scrollBarGroove
	}
}
