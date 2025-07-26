#ifndef _PREFERENCES_PDFFILE_H_
#define _PREFERENCES_PDFFILE_H_

#include "PDFBridge/PDFFile.h"

#include <string>
#include <memory>

namespace Preferences {

class PDFFile {
private:
	::PDFFile &pdfFile;
	std::unique_ptr<::PDFFile> pdfFileCopy;
public:
	PDFFile(::PDFFile &PDFFile);

	void render(bool shown);
	void save();
	void cancel();
	void clear();
};

} // namespace Preferences

#endif
