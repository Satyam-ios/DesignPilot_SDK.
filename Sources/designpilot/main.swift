import Foundation
import DesignPilotSDK
import DesignPilotEngine

struct DesignPilotCLI {
    static func main() async {
        let args = CommandLine.arguments

        if args.count <= 1 || args.contains("--help") || args.contains("-h") {
            printHelp()
            return
        }

        if args.contains("--version") || args.contains("-v") {
            print("DesignPilot CLI v\(DesignPilotSDK.version) (Swift 6.0 Engine)")
            return
        }

        let command = args[1].lowercased()

        switch command {
        case "daemon":
            await runDaemon(args: Array(args.dropFirst(2)))
        case "inspect":
            runInspect(args: Array(args.dropFirst(2)))
        case "generate":
            await runGenerate(args: Array(args.dropFirst(2)))
        case "rollback":
            runRollback(args: Array(args.dropFirst(2)))
        default:
            print("Unknown command: '\(command)'. Run 'designpilot --help' for usage.")
        }
    }

    static func printHelp() {
        print("""
        DesignPilot CLI — AI-Powered Figma & PDF-to-Xcode UI Generator
        Version \(DesignPilotSDK.version)

        USAGE:
            designpilot <subcommand> [options]

        SUBCOMMANDS:
            daemon       Launch local HTTP engine daemon for Xcode & iOS Simulator (default port 8088)
            inspect      Inspect target Xcode project (architecture, deployment target, Swift version)
            generate     Run end-to-end design-to-code generation (Figma URL or PDF)
            rollback     Restore project to a previous snapshot backup

        EXAMPLES:
            # Generate from Figma URL
            designpilot generate "https://www.figma.com/design/KEY/Title?node-id=0:1" --output Views/Generated

            # Generate from PDF design flow export
            designpilot generate --pdf "Designs/ContextToCall_IoT_Flow.pdf" --page 1 --output Views/Generated

            # Inspect target project
            designpilot inspect --path .

            # Start local background engine daemon
            designpilot daemon --port 8088
        """)
    }

    static func runDaemon(args: [String]) async {
        var port: UInt16 = 8088
        if let portIdx = args.firstIndex(of: "--port"), portIdx + 1 < args.count {
            port = UInt16(args[portIdx + 1]) ?? 8088
        }

        print("🚀 Starting DesignPilot Engine daemon on port \(port)...")
        let server = EngineServer(port: port)
        do {
            try server.start()
            print("✅ DesignPilot Engine daemon is online.")
            print("👉 Open your Xcode project with DesignPilotView() to start generating UI.")
            print("Press Ctrl+C to terminate.")

            // Keep process running
            while true {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        } catch {
            print("❌ Failed to start engine daemon: \(error.localizedDescription)")
        }
    }

    static func runInspect(args: [String]) {
        var path = FileManager.default.currentDirectoryPath
        if let pathIdx = args.firstIndex(of: "--path"), pathIdx + 1 < args.count {
            path = args[pathIdx + 1]
        }

        print("🔍 Inspecting target project at: \(path)")
        let inspector = XcodeProjectInspector()
        do {
            let arch = try inspector.inspect(projectPath: path)
            print("""
            --------------------------------------------------
            Project Name:          \(arch.projectName)
            Primary Framework:     \(arch.primaryFramework.rawValue)
            Swift Version:         \(arch.swiftVersion)
            Minimum Target:        iOS \(arch.minDeploymentTarget)
            Views Directory:       \(arch.existingViewsDirectory ?? "None detected (Default: Views/Generated)")
            Asset Catalogs:        \(arch.assetCatalogPaths.joined(separator: ", "))
            Supported Devices:     \(arch.supportedDeviceFamilies.joined(separator: ", "))
            Available Simulators:  \(arch.availableSimulators.count) device(s)
            --------------------------------------------------
            """)
        } catch {
            print("❌ Inspection failed: \(error.localizedDescription)")
        }
    }

    static func runGenerate(args: [String]) async {
        var pdfPath: String?
        var figmaUrlString: String?
        var pageNumber: Int = 1

        if let pdfIdx = args.firstIndex(of: "--pdf"), pdfIdx + 1 < args.count {
            pdfPath = args[pdfIdx + 1]
        }
        if let pageIdx = args.firstIndex(of: "--page"), pageIdx + 1 < args.count {
            pageNumber = Int(args[pageIdx + 1]) ?? 1
        }

        if pdfPath == nil {
            if let firstArg = args.first, !firstArg.hasPrefix("--") {
                if firstArg.lowercased().hasSuffix(".pdf") {
                    pdfPath = firstArg
                } else {
                    figmaUrlString = firstArg
                }
            }
        }

        guard pdfPath != nil || figmaUrlString != nil else {
            print("Error: Missing Figma URL or PDF path. Usage:")
            print("  designpilot generate <figma-url> [--output <path>]")
            print("  designpilot generate --pdf <path-to-pdf> [--page <number>] [--output <path>]")
            return
        }

        var outputDir = "Views/Generated"
        if let outIdx = args.firstIndex(of: "--output"), outIdx + 1 < args.count {
            outputDir = args[outIdx + 1]
        }

        var projectRoot = FileManager.default.currentDirectoryPath
        if let projIdx = args.firstIndex(of: "--project"), projIdx + 1 < args.count {
            projectRoot = args[projIdx + 1]
        }

        var framework: TargetFramework = .swiftUI
        if let fwIdx = args.firstIndex(of: "--framework"), fwIdx + 1 < args.count {
            if args[fwIdx + 1].lowercased() == "uikit" {
                framework = .uiKit
            }
        }

        do {
            let request: GenerationRequest
            if let pdf = pdfPath {
                print("📄 Loading design from PDF: \(pdf) (Page \(pageNumber))...")
                let fileURL = URL(fileURLWithPath: pdf)
                let fileName = fileURL.lastPathComponent
                let fileData = try? Data(contentsOf: fileURL)
                let fileSize = fileData?.count ?? 0

                let pdfInfo = PDFSourceInfo(
                    filePath: pdf,
                    fileName: fileName,
                    pageCount: 1,
                    selectedPage: pageNumber,
                    fileSizeInBytes: fileSize,
                    fileData: fileData
                )
                request = GenerationRequest(
                    source: .pdf(pdfInfo),
                    preferredFramework: framework,
                    targetDirectory: outputDir,
                    visualAcceptanceThreshold: 0.95,
                    maxVisualIterations: 3
                )
            } else if let urlStr = figmaUrlString {
                print("⚡ Parsing Figma URL: \(urlStr)...")
                let figmaURL = try FigmaURL.parse(urlStr)
                request = GenerationRequest(
                    figmaURL: figmaURL,
                    preferredFramework: framework,
                    targetDirectory: outputDir,
                    visualAcceptanceThreshold: 0.95,
                    maxVisualIterations: 3
                )
            } else {
                return
            }

            print("📦 Connecting to Generation Engine...")
            let server = EngineServer()
            let result = try await server.executeGeneration(request: request)

            print("\n✨ Application Generation Complete for: '\(result.screenName)'")
            print("   Source:            \(result.source.displayName)")
            print("   Architecture:      \(result.architectureSummary.pattern)")
            print("   Visual Match:      \(result.visualDiff.similarityPercentageFormatted)")
            print("   Toolchain Build:   \(result.buildReport.isSuccess ? "✅ Succeeded" : "❌ Failed") (\(String(format: "%.1fs", result.buildReport.durationSeconds))) [Auto-fixed: \(result.buildReport.fixedErrorsCount)]")
            print("   Automated Tests:   ✅ \(result.testReport.passedTests)/\(result.testReport.totalTests) Passed (\(String(format: "%.2fs", result.testReport.durationSeconds))) [\(result.testReport.testSuites.joined(separator: ", "))]")

            print("\n📁 Generated Architecture Files (\(result.generatedFiles.count)):")
            for file in result.generatedFiles {
                print("   [\(file.framework.rawValue)] [\(file.status.rawValue)] \(file.relativePath) (\(file.lineCount) lines)")
            }

            if !result.architectureSummary.remainingIntegrationPoints.isEmpty {
                print("\n📋 Post-Integration Requirements:")
                for point in result.architectureSummary.remainingIntegrationPoints {
                    print("   - \(point)")
                }
            }

            print("\n🚀 Committing staged files to project...")
            let integrator = SafeFileIntegrator()
            let summary = try integrator.commit(
                selectedFilePaths: result.generatedFiles.map(\.relativePath),
                projectRoot: projectRoot
            )

            print("✅ Successfully integrated files into project!")
            print("   Backup created at: \(summary.backupPath)")
            print("   Rollback command:  designpilot rollback --backup-id \(summary.backupId)")
        } catch {
            print("❌ Generation failed: \(error.localizedDescription)")
        }
    }

    static func runRollback(args: [String]) {
        guard let bIdx = args.firstIndex(of: "--backup-id"), bIdx + 1 < args.count else {
            print("Error: Missing backup ID. Usage: designpilot rollback --backup-id <id>")
            return
        }
        let backupId = args[bIdx + 1]
        let integrator = SafeFileIntegrator()
        do {
            let success = try integrator.rollback(backupId: backupId)
            if success {
                print("✅ Successfully rolled back project to snapshot: \(backupId)")
            } else {
                print("❌ Rollback failed.")
            }
        } catch {
            print("❌ Rollback error: \(error.localizedDescription)")
        }
    }
}

await DesignPilotCLI.main()
