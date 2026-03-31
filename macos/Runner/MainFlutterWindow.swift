import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var flutterViewController: FlutterViewController?

  override func awakeFromNib() {
    let controller = FlutterViewController()
    self.flutterViewController = controller

    // iPhone 16 Pro Max 尺寸: 430 x 932 点
    let iPhone16ProMaxWidth: CGFloat = 430
    let iPhone16ProMaxHeight: CGFloat = 932

    // 计算窗口大小（包含标题栏等）
    let contentRect = NSRect(x: 0, y: 0, width: iPhone16ProMaxWidth, height: iPhone16ProMaxHeight)
    let windowRect = self.frameRect(forContentRect: contentRect)

    // 设置窗口大小和位置（居中显示）
    if let screen = NSScreen.main {
      let screenRect = screen.visibleFrame
      let x = screenRect.midX - windowRect.width / 2
      let y = screenRect.midY - windowRect.height / 2
      let centeredRect = NSRect(x: x, y: y, width: windowRect.width, height: windowRect.height)
      self.setFrame(centeredRect, display: true)
    } else {
      self.setFrame(windowRect, display: true)
    }

    // 设置最小和最大窗口大小
    self.minSize = NSSize(width: iPhone16ProMaxWidth, height: iPhone16ProMaxHeight)
    self.maxSize = NSSize(width: iPhone16ProMaxWidth * 2, height: iPhone16ProMaxHeight * 2)

    self.contentViewController = controller

    RegisterGeneratedPlugins(registry: controller)

    // 手动注册 charset_converter 插件（使用自定义实现）
    CharsetConverterPlugin.register(with: controller.registrar(forPlugin: "CharsetConverterPlugin"))

    super.awakeFromNib()
  }

  // 确保窗口在后台时也能继续渲染
  // 解决问题：macOS 窗口不在前台时启动页面会卡住
  override var canBecomeKey: Bool {
    return true
  }

  override var canBecomeMain: Bool {
    return true
  }

  // 允许窗口在非活动状态下接收鼠标事件（包括滚动）
  // 解决问题：失去焦点后无法滚动
  override var acceptsMouseMovedEvents: Bool {
    get { return true }
    set { }
  }

  // 重写 sendEvent 以支持非活动窗口的滚动事件
  // 这是解决 Flutter macOS 在后台窗口不响应滚动的关键
  override func sendEvent(_ event: NSEvent) {
    // 处理滚动事件，即使窗口不是 key window
    if event.type == .scrollWheel {
      // 直接将滚动事件传递给 FlutterViewController
      flutterViewController?.view.scrollWheel(with: event)
      return
    }
    super.sendEvent(event)
  }
}
