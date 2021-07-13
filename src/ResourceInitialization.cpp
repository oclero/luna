#include <luna/ResourceInitialization.hpp>

#include <qglobal.h>

// This must be done outside of any namespace.
void lunaResourceInitialization() {
	Q_INIT_RESOURCE(qml);
	Q_INIT_RESOURCE(resources);
}

namespace luna {
void initializeResources() {
	lunaResourceInitialization();
}
} // namespace luna
