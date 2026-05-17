@testable import Ghostty
import AppKit
import Testing

struct SurfaceViewAppKitTests {
    @Test(arguments: [
        ("\u{0008}", true),
        ("\u{001F}", true),
        ("\u{007F}", false),
        (" ", false),
        ("h", false),
        ("", false),
        ("\u{0009}x", false),
        ("\u{0009}\u{0009}", false),
    ])
    func suppressesOnlySingleC0ControlTextWhileComposing(
        text: String,
        expected: Bool
    ) {
        #expect(
            Ghostty.SurfaceView.shouldSuppressComposingControlInput(
                text,
                composing: true
            ) == expected
        )
    }

    @Test(arguments: [
        ("\u{0003}", true),
        ("\u{0016}", true),
        ("\u{0008}", false),
        ("\u{001F}", false),
        ("h", false),
        ("", false),
    ])
    func allowsOnlyCtrlCAndCtrlVWhileComposing(
        text: String,
        expected: Bool
    ) {
        #expect(
            Ghostty.SurfaceView.shouldAllowComposingTerminalControlInput(
                text,
                composing: true
            ) == expected
        )
    }

    @Test(arguments: [
        ("c", UInt16(0x08), true),
        ("v", UInt16(0x09), true),
        ("x", UInt16(0x07), false),
    ])
    func bypassesTextInputForCtrlCAndCtrlV(
        key: String,
        keyCode: UInt16,
        expected: Bool
    ) {
        let event = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: .control,
            timestamp: 1,
            windowNumber: 0,
            context: nil,
            characters: key,
            charactersIgnoringModifiers: key,
            isARepeat: false,
            keyCode: keyCode
        )!

        #expect(
            Ghostty.SurfaceView.shouldBypassTextInputForTerminalControlInput(event) == expected
        )
    }

    @Test(arguments: [
        NSEvent.ModifierFlags([.control, .shift]),
        NSEvent.ModifierFlags([.control, .option]),
        NSEvent.ModifierFlags([.control, .command]),
    ])
    func doesNotBypassTextInputForModifiedCtrlC(
        modifiers: NSEvent.ModifierFlags
    ) {
        let event = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: modifiers,
            timestamp: 1,
            windowNumber: 0,
            context: nil,
            characters: "c",
            charactersIgnoringModifiers: "c",
            isARepeat: false,
            keyCode: 0x08
        )!

        #expect(
            Ghostty.SurfaceView.shouldBypassTextInputForTerminalControlInput(event) == false
        )
    }

    @Test func doesNotSuppressControlTextWhenNotComposing() {
        #expect(
            Ghostty.SurfaceView.shouldSuppressComposingControlInput(
                "\u{0008}",
                composing: false
            ) == false
        )
    }

    @Test func doesNotSuppressMissingText() {
        #expect(
            Ghostty.SurfaceView.shouldSuppressComposingControlInput(
                nil,
                composing: true
            ) == false
        )
    }
}
