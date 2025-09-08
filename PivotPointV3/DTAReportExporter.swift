import Foundation
import UIKit
import PDFKit

class DTAReportExporter {
    
    // MARK: - KML EXPORT
    func generateKML(for report: DTAReport) -> String {
        let reportData = getFullReportData(report: report)
        let dataHtml = reportData.map { "<b>\($0.label):</b> \($0.value)" }.joined(separator: "<br>")
        
        var kml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(sanitizeXMLString(report.reportTitle ?? "DTA Report"))</name>
            <description><![CDATA[
              <h2>Pivot Point: Practical Forestry Solutions</h2>
              <p><i>PRAEMONITUS PRAEMUNITUS</i></p>
              <hr>
              \(dataHtml)
            ]]></description>
        """
        
        // Enhanced waypoint placemarks with proper labeling and comprehensive data
        for waypoint in report.waypointsArray {
            let waypointType = waypoint.isStartPoint ? "Start" : waypoint.isEndPoint ? "End" : "Spot"

            // Format: (Start/End/Spot) + Date + Activity
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: report.manualDateTime ?? Date())
            let activity = report.activity?.isEmpty == false ? report.activity! : "No Activity"
            let waypointTitle = "\(waypointType) - \(dateString) - \(activity)"

            var description = """
            <div style='font-family: Arial, sans-serif;'>
            <h2 style='color: #2c5aa0; margin-bottom: 10px;'>\(sanitizeXMLString(waypointTitle))</h2>
            <table style='border-collapse: collapse; width: 100%;'>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd;'>Type:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(waypointType) Point</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd;'>Coordinates:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(waypoint.ddmCoordinateString)</td></tr>
            """

            if let notes = waypoint.locationNotes, !notes.isEmpty {
                description += "<tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd;'>Notes:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(notes))</td></tr>"
            }

            description += "</table>"

            // Add comprehensive DTA report information
            description += """
            <h3 style='color: #2c5aa0; margin-top: 15px;'>DTA Report Summary</h3>
            <table style='border-collapse: collapse; width: 100%;'>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Report Title:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(report.reportTitle ?? "N/A"))</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Fire Number:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(report.fireNumber ?? "N/A"))</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Fire Center:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(report.fireCenter ?? "N/A"))</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Assessed By:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(report.assessedBy ?? "N/A"))</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Activity:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(report.activity ?? "N/A"))</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Level of Disturbance:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(report.levelOfDisturbance ?? "N/A"))</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Area Safe for Work:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(report.areaBetweenPointsSafeForWork ? "Yes" : "No")</td></tr>
            <tr><td style='font-weight: bold; padding: 5px; border: 1px solid #ddd; background-color: #e9e9e9;'>Reassessment Needed:</td><td style='padding: 5px; border: 1px solid #ddd;'>\(sanitizeXMLString(report.reassessmentNeeded ?? "N/A"))</td></tr>
            </table>
            """

            // Add embedded photo if available
            if let photoData = findPhotoData(for: waypoint, report: report) {
                let base64String = photoData.base64EncodedString()
                description += "<h3 style='color: #2c5aa0; margin-top: 15px;'>Associated Photo</h3>"
                description += "<img src='data:image/jpeg;base64,\(base64String)' style='max-width: 400px; border: 2px solid #ddd; border-radius: 5px;' />"
            }

            description += "</div>"

            kml += """
              <Placemark>
                <name>\(sanitizeXMLString(waypointTitle))</name>
                <description><![CDATA[\(description)]]></description>
                <Point>
                  <coordinates>\(waypoint.longitude),\(waypoint.latitude),0</coordinates>
                </Point>
              </Placemark>
            """
        }
        
        // Note: DTA report data is now embedded in each waypoint instead of separate placemark
        
        kml += "</Document></kml>"
        return kml
    }

    // MARK: - CSV EXPORT
    func generateCSV(for report: DTAReport) -> String {
        let reportData = getFullReportData(report: report)
        
        var csv = "\"Pivot Point: Practical Forestry Solutions\"\n"
        csv += "\"PRAEMONITUS PRAEMUNITUS\"\n"
        csv += "\"DTA Report - \(sanitizeCSVString(report.reportTitle ?? ""))\"\n\n"
        
        var currentCategory = ""
        for item in reportData {
            if item.category != currentCategory {
                csv += "\n\"**\(item.category.uppercased())**\",\n"
                currentCategory = item.category
            }
            csv += "\"\(sanitizeCSVString(item.label))\",\"\(sanitizeCSVString(item.value))\"\n"
        }
        
        // Enhanced waypoints section with clear structure
        csv += "\n\"**WAYPOINTS SUMMARY**\",\n"
        csv += "\"Type\",\"Label\",\"Coordinates\",\"Notes\",\"Photo Filename\"\n"
        for waypoint in report.waypointsArray {
            let waypointType = waypoint.isStartPoint ? "Start Point" : waypoint.isEndPoint ? "End Point" : "Spot Waypoint"
            let photoFile = findPhoto(for: waypoint, report: report)?.fileName ?? ""
            csv += "\"\(waypointType)\",\"\(sanitizeCSVString(waypoint.label ?? ""))\",\"\(waypoint.ddmCoordinateString)\",\"\(sanitizeCSVString(waypoint.locationNotes ?? ""))\",\"\(photoFile)\"\n"
        }

        // Enhanced media attachments section
        csv += "\n\"**MEDIA ATTACHMENTS**\",\n"
        csv += "\"Filename\",\"Description\",\"Timestamp\"\n"
        for attachment in report.mediaAttachmentsArray {
            let description = attachment.fileName?.replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: "_", with: " ") ?? "Unnamed Photo"
            let timestamp = formatDateForCSV(attachment.photoTimestamp ?? Date())
            csv += "\"\(sanitizeCSVString(attachment.fileName ?? ""))\",\"\(sanitizeCSVString(description))\",\"\(timestamp)\"\n"
        }

        // Enhanced fuel types section for analysis
        let fuelTypes = report.fuelTypes as? Set<FuelTypeSelection> ?? []
        if !fuelTypes.isEmpty {
            csv += "\n\"**FUEL TYPES BREAKDOWN**\",\n"
            csv += "\"Fuel Type\",\"Percentage\",\"Code\"\n"
            for fuelType in fuelTypes.sorted(by: { $0.fuelType ?? "" < $1.fuelType ?? "" }) {
                let code = fuelType.fuelType?.split(separator: " ").first ?? ""
                csv += "\"\(sanitizeCSVString(fuelType.fuelType ?? ""))\",\"\(fuelType.percentage)%\",\"\(code)\"\n"
            }
        }
        
        return csv
    }

    // MARK: - PDF EXPORT
    func generatePDF(for report: DTAReport) -> Data {
        let reportData = getFullReportData(report: report)
        let pdfMetaData = [kCGPDFContextCreator: "Pivot Point"]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()
            var currentY: CGFloat = 30
            let margin: CGFloat = 40
            let contentWidth = pageSize.width - 2 * margin
            
            // Draw complete header (image + text) for exports - use HeaderLight for black lettering
            if let headerImage = UIImage(named: "HeaderLight") {
                let imageWidth: CGFloat = 200
                let imageHeight = (imageWidth / headerImage.size.width) * headerImage.size.height
                let imageRect = CGRect(x: (pageSize.width - imageWidth) / 2, y: currentY, width: imageWidth, height: imageHeight)
                headerImage.draw(in: imageRect)
                currentY += imageHeight + 5

                // Add the header text "PRAEMONITUS PRAEMUNITUS"
                let headerText = "PRAEMONITUS PRAEMUNITUS"
                let headerTextAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                    .foregroundColor: UIColor.systemGray
                ]
                let headerTextSize = headerText.size(withAttributes: headerTextAttributes)
                let headerTextRect = CGRect(x: (pageSize.width - headerTextSize.width) / 2, y: currentY, width: headerTextSize.width, height: headerTextSize.height)
                headerText.draw(in: headerTextRect, withAttributes: headerTextAttributes)
                currentY += headerTextSize.height + 20
            }
            
            // Professional section-based layout
            var currentCategory = ""
            for item in reportData {
                if currentY > 720 {
                    context.beginPage()
                    currentY = margin
                }

                if item.category != currentCategory {
                    currentY += 15
                    // Draw section header with black background
                    let sectionHeaderRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 20)
                    context.cgContext.setFillColor(UIColor.black.cgColor)
                    context.cgContext.fill(sectionHeaderRect)

                    currentY = drawPDFText(text: item.category.uppercased(), at: currentY + 3, on: context.cgContext, width: contentWidth, margin: margin + 5, font: .boldSystemFont(ofSize: 12), color: .white)
                    currentY += 5
                    currentCategory = item.category
                }

                // Draw field with improved formatting
                let labelFont = UIFont.systemFont(ofSize: 10, weight: .medium)
                let valueFont = UIFont.systemFont(ofSize: 10)

                currentY = drawPDFText(text: "\(item.label):", at: currentY, on: context.cgContext, width: contentWidth * 0.4, margin: margin + 15, font: labelFont, color: .darkGray)
                currentY -= 14 // Move back up to align value with label
                currentY = drawPDFText(text: item.value, at: currentY, on: context.cgContext, width: contentWidth * 0.55, margin: margin + contentWidth * 0.45, font: valueFont, color: .black)
                currentY += 2
            }
            
            // Professional photo section
            if !report.mediaAttachmentsArray.isEmpty {
                if currentY > 600 {
                    context.beginPage()
                    currentY = margin
                }

                currentY += 15
                // Draw photo section header with black background
                let photoHeaderRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 20)
                context.cgContext.setFillColor(UIColor.black.cgColor)
                context.cgContext.fill(photoHeaderRect)
                currentY = drawPDFText(text: "ATTACHED PHOTOS", at: currentY + 3, on: context.cgContext, width: contentWidth, margin: margin + 5, font: .boldSystemFont(ofSize: 12), color: .white)
                currentY += 10

                for (index, attachment) in report.mediaAttachmentsArray.enumerated() {
                    if let data = findData(for: attachment), let image = UIImage(data: data) {
                        let availableHeight = 792 - currentY - margin - 60 // Reserve space for caption
                        let imageAspectRatio = image.size.width / image.size.height
                        let maxDisplayWidth = contentWidth * 0.8 // Slightly smaller for better layout
                        let maxDisplayHeight = min(200, availableHeight) // Limit height for consistency

                        let displayWidth = min(maxDisplayWidth, maxDisplayHeight * imageAspectRatio)
                        let displayHeight = displayWidth / imageAspectRatio

                        if displayHeight > availableHeight {
                            context.beginPage()
                            currentY = margin
                        }

                        // Center the image
                        let imageX = margin + (contentWidth - displayWidth) / 2
                        let imageRect = CGRect(x: imageX, y: currentY, width: displayWidth, height: displayHeight)

                        // Draw border around image
                        context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                        context.cgContext.setLineWidth(1)
                        context.cgContext.stroke(imageRect)

                        image.draw(in: imageRect)
                        currentY += displayHeight + 8

                        // Professional caption
                        let photoDescription = attachment.fileName?.replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: "_", with: " ") ?? "Photo \(index + 1)"
                        let timestamp = formatDateForPDF(attachment.photoTimestamp ?? Date())
                        let caption = "Figure \(index + 1): \(photoDescription)\nTaken: \(timestamp)"

                        currentY = drawPDFText(text: caption, at: currentY, on: context.cgContext, width: contentWidth, margin: margin, font: .systemFont(ofSize: 9), color: .darkGray)
                        currentY += 15
                    }
                }
            }
        }
        return data
    }
    
    // MARK: - Private Helpers
    private func getFullReportData(report: DTAReport) -> [(category: String, label: String, value: String)] {
        // FIXED: Declared as an array of NAMED tuples
        var data: [(category: String, label: String, value: String)] = []
        let na = "N/A"

        // FIXED: Appending NAMED tuples
        data.append((category: "Metadata", label: "Report Title", value: report.reportTitle ?? na))
        data.append((category: "Metadata", label: "Fire Number", value: report.fireNumber ?? na))
        data.append((category: "Metadata", label: "Fire Center", value: report.fireCenter ?? na))
        data.append((category: "Metadata", label: "Assessed By", value: report.assessedBy ?? na))
        data.append((category: "Metadata", label: "DTF Completed By", value: report.dtfCompletedBy ?? na))
        data.append((category: "Metadata", label: "Assessment Date", value: formatDateForPDF(report.manualDateTime ?? Date())))
        
        data.append((category: "Daily Assessment", label: "SAO Overview", value: report.saoOverview ?? na))
        data.append((category: "Daily Assessment", label: "SAO Briefed to Crew", value: report.saoBriefedToCrew ? "Yes" : "No"))
        if !report.saoComment.isNilOrEmpty { data.append((category: "Daily Assessment", label: "SAO Comments", value: report.saoComment!)) }
        data.append((category: "Daily Assessment", label: "Primary Hazards Present", value: report.primaryHazardsPresent ?? na))
        data.append((category: "Daily Assessment", label: "Activity", value: report.activity ?? na))
        
        data.append((category: "Level of Disturbance", label: "Level of Disturbance", value: report.levelOfDisturbance ?? na))
        data.append((category: "Level of Disturbance", label: "LoD Low Hazards", value: report.lodLowHazards ?? na))
        data.append((category: "Level of Disturbance", label: "LoD Moderate (Fir/Larch/Pine/Spruce)", value: report.lodMediumFirLarchPineSpruce ?? na))
        data.append((category: "Level of Disturbance", label: "LoD Moderate (Red/Yellow Cedar)", value: report.lodMediumRedYellowCedar ?? na))
        
        let fuelTypes = report.fuelTypes as? Set<FuelTypeSelection> ?? []
        for fuelType in fuelTypes.sorted(by: { $0.fuelType ?? "" < $1.fuelType ?? "" }) {
            data.append((category: "Fuel Types", label: fuelType.fuelType ?? "Unknown", value: "\(fuelType.percentage)%"))
        }

        data.append((category: "Assessment Protocol", label: "DTA Marking Protocol Followed", value: report.dtaMarkingProtocolFollowed ?? na))
        if !report.dtaMarkingProtocolComment.isNilOrEmpty { data.append((category: "Assessment Protocol", label: "DTA Protocol Comment", value: report.dtaMarkingProtocolComment!)) }
        data.append((category: "Assessment Protocol", label: "Estimated Trees Felled", value: "\(report.estimatedTreesFelled)"))
        data.append((category: "Assessment Protocol", label: "No Work Zones Present", value: report.noWorkZonesPresent ?? na))
        data.append((category: "Assessment Protocol", label: "No Work Zones Identified & Communicated", value: report.noWorkZones ? "Yes" : "No"))
        data.append((category: "Assessment Protocol", label: "Assessed min. 1.5 TL from work area", value: report.assessedMin1_5TreeLengths ?? na))
        if !report.assessedTLComment.isNilOrEmpty { data.append((category: "Assessment Protocol", label: "1.5 TL Comment", value: report.assessedTLComment!)) }
        data.append((category: "Assessment Protocol", label: "Distance from Work Area", value: report.assessedDistanceFromWorkArea ?? na))
        data.append((category: "Assessment Protocol", label: "Area between start and end safe for work", value: report.areaBetweenPointsSafeForWork ? "Yes" : "No"))
        if !report.areaSafeForWorkComment.isNilOrEmpty { data.append((category: "Assessment Protocol", label: "Area Safety Comment", value: report.areaSafeForWorkComment!)) }
        data.append((category: "Assessment Protocol", label: "Reassessment Needed", value: report.reassessmentNeeded ?? na))
        
        if !report.comments.isNilOrEmpty { data.append((category: "Comments", label: "Additional Comments", value: report.comments!)) }

        // Add waypoints section
        for waypoint in report.waypointsArray {
            let waypointType = waypoint.isStartPoint ? "Start Point" : waypoint.isEndPoint ? "End Point" : "Spot Waypoint"
            data.append((category: "Waypoints", label: "\(waypointType) - \(waypoint.label ?? "Unnamed")", value: waypoint.ddmCoordinateString))
            if let notes = waypoint.locationNotes, !notes.isEmpty {
                data.append((category: "Waypoints", label: "\(waypointType) Notes", value: notes))
            }
        }

        // Add media attachments section
        for attachment in report.mediaAttachmentsArray {
            let attachmentName = attachment.fileName?.replacingOccurrences(of: ".jpg", with: "") ?? "Unnamed Photo"
            let timestamp = formatDateForPDF(attachment.photoTimestamp ?? Date())
            data.append((category: "Media Attachments", label: attachmentName, value: "Photo taken on \(timestamp)"))
        }

        // The filter now works correctly because the elements have a '.value' member.
        return data.filter { !$0.value.isEmpty && $0.value != na }
    }

    private func findPhoto(for waypoint: DTAWaypoint, report: DTAReport) -> MediaAttachment? {
        guard waypoint.isSpotPoint else { return nil }
        
        let spotLabel = sanitizeForFileName(waypoint.label ?? "Spot")
        let notes = sanitizeForFileName(waypoint.locationNotes ?? "")
        let expectedFileName = notes.isEmpty ? "\(spotLabel).jpg" : "\(spotLabel)-\(notes).jpg"

        return report.mediaAttachmentsArray.first { $0.fileName == expectedFileName }
    }
    
    private func sanitizeForFileName(_ string: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>: ")
        return string.components(separatedBy: invalidCharacters).joined(separator: "_")
    }

    private func findPhotoData(for waypoint: DTAWaypoint, report: DTAReport) -> Data? {
        guard let attachment = findPhoto(for: waypoint, report: report) else { return nil }
        return findData(for: attachment)
    }
    
    private func findData(for attachment: MediaAttachment) -> Data? {
        guard let fileName = attachment.fileName, let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileUrl = docsUrl.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileUrl)
    }

    private func drawPDFText(text: String, at y: CGFloat, on context: CGContext, width: CGFloat, margin: CGFloat, font: UIFont = .systemFont(ofSize: 11), color: UIColor = .black) -> CGFloat {
        let attributedString = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        let size = attributedString.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        attributedString.draw(in: CGRect(x: margin, y: y, width: width, height: size.height))
        return y + size.height + 4
    }
    
    private func sanitizeXMLString(_ input: String) -> String {
        var sanitized = input
        sanitized = sanitized.replacingOccurrences(of: "&", with: "&amp;")
        sanitized = sanitized.replacingOccurrences(of: "<", with: "&lt;")
        sanitized = sanitized.replacingOccurrences(of: ">", with: "&gt;")
        sanitized = sanitized.replacingOccurrences(of: "\"", with: "&quot;")
        sanitized = sanitized.replacingOccurrences(of: "'", with: "&apos;")
        return sanitized
    }

    private func sanitizeCSVString(_ input: String) -> String {
        let needsQuotes = input.contains(",") || input.contains("\n") || input.contains("\"")
        var sanitized = input.replacingOccurrences(of: "\"", with: "\"\"")
        if needsQuotes {
            sanitized = "\"\(sanitized)\""
        }
        return sanitized
    }
    
    private func formatDateForPDF(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }

    private func formatDateForCSV(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
}
