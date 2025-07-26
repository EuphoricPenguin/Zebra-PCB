#include "PDFFile.h"

#include "imgui/imgui.h"
#include "imgui/misc/cpp/imgui_stdlib.h"

#include "platform.h"

namespace Preferences {

PDFFile::PDFFile(::PDFFile &pdfFile) : pdfFile(pdfFile) {
	// pdfFileCopy is initialized as nullptr and will be created when needed
}

void PDFFile::save() {
	pdfFile.writeToConfig(pdfFile.configFilepath);
	pdfFile.reload();
}

void PDFFile::cancel() {
	if (pdfFileCopy) {
		pdfFile = *pdfFileCopy;
	}
}

void PDFFile::clear() {
	pdfFile.path = filesystem::path{};
	pdfFile.close();
}

void PDFFile::render(bool shown) {
	static bool wasShown = false;

	if (shown) {
		if (!wasShown) { // Panel just got opened
			// Create a copy to be able to restore if cancelled
			pdfFileCopy = std::make_unique<::PDFFile>(pdfFile);
		}

		ImGui::Text("PDF file settings");

		std::string pdfFilePath = pdfFile.path.string();
		if (ImGui::InputText("PDF File", &pdfFilePath)) {
			pdfFile.path = pdfFilePath;
		}
		ImGui::SameLine();
		if (ImGui::Button("Browse##pdfFilePath")) {
			auto path = show_file_picker();
			if (!path.empty()) {
				pdfFilePath = path.string();
				pdfFile.path = path;
			}
		}
	} else {
		// Panel is closed, reset the copy
		pdfFileCopy.reset();
	}

	wasShown = shown;
}

} // namespace Preferences
