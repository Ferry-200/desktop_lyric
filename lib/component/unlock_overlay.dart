// #include <windows.h>

// // 定义窗口过程
// LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
//     switch (uMsg) {
//     case WM_CREATE:
//         // 在窗口上创建一个按钮
//         CreateWindow(
//             "BUTTON",  // 按钮类名
//             "解锁",     // 按钮文本
//             WS_VISIBLE | WS_CHILD, // 按钮样式
//             10, 10, 80, 30,        // 按钮位置和大小
//             hwnd,                  // 父窗口句柄
//             (HMENU)1,              // 按钮ID
//             (HINSTANCE)GetWindowLongPtr(hwnd, GWLP_HINSTANCE),
//             NULL
//         );
//         break;
//     case WM_COMMAND:
//         if (LOWORD(wParam) == 1) {
//             MessageBox(hwnd, "按钮被点击", "提示", MB_OK);
//         }
//         break;
//     case WM_DESTROY:
//         PostQuitMessage(0);
//         break;
//     default:
//         return DefWindowProc(hwnd, uMsg, wParam, lParam);
//     }
//     return 0;
// }

// // 主函数
// int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
//     const char CLASS_NAME[] = "Sample Window Class";

//     WNDCLASS wc = { };

//     wc.lpfnWndProc = WindowProc;
//     wc.hInstance = hInstance;
//     wc.lpszClassName = CLASS_NAME;

//     RegisterClass(&wc);

//     // 创建无边框窗口
//     HWND hwnd = CreateWindowEx(
//         WS_EX_TOPMOST | WS_EX_LAYERED | WS_EX_TOOLWINDOW, // 扩展样式
//         CLASS_NAME,       // 窗口类名
//         "Overlay",        // 窗口标题
//         WS_POPUP,         // 窗口样式
//         0, 0, 100, 50,    // 窗口位置和大小
//         NULL,             // 父窗口句柄
//         NULL,             // 菜单句柄
//         hInstance,        // 实例句柄
//         NULL              // 附加参数
//     );

//     if (hwnd == NULL) {
//         return 0;
//     }

//     // 设置窗口透明背景
//     SetLayeredWindowAttributes(hwnd, 0, (255 * 70) / 100, LWA_ALPHA); // 设置窗口透明度为70%

//     // 显示窗口
//     ShowWindow(hwnd, nCmdShow);

//     // 定位到指定窗口左上角
//     HWND targetWindow = FindWindow(NULL, "Target Window Title"); // 替换 "Target Window Title" 为目标窗口的标题
//     if (targetWindow) {
//         RECT targetRect;
//         GetWindowRect(targetWindow, &targetRect);
//         SetWindowPos(hwnd, HWND_TOPMOST, targetRect.left, targetRect.top, 100, 50, SWP_SHOWWINDOW);
//     }

//     // 进入消息循环
//     MSG msg = { };
//     while (GetMessage(&msg, NULL, 0, 0)) {
//         TranslateMessage(&msg);
//         DispatchMessage(&msg);
//     }

//     return 0;
// }

// Basic Petzoldian "hello world" Win32 app

import 'dart:ffi';

import 'package:ffi/ffi.dart' as ffi;
import 'package:win32/win32.dart' as win32;

int mainWindowProc(int hWnd, int uMsg, int wParam, int lParam) {
  switch (uMsg) {
    case win32.WM_CREATE:
      win32.CreateWindow(
        win32.TEXT("BUTTON"),
        win32.TEXT("UNLOCK"),
        win32.WINDOW_STYLE.WS_VISIBLE | win32.WINDOW_STYLE.WS_CHILD,
        10,
        10,
        80,
        30,
        hWnd,
        1,
        win32.GetWindowLongPtr(
          hWnd,
          win32.WINDOW_LONG_PTR_INDEX.GWLP_HINSTANCE,
        ),
        nullptr,
      );
      break;
    case win32.WM_COMMAND:
      if (win32.LOWORD(wParam) == 1) {
        final parentHwnd = win32.GetWindowLongPtr(
          hWnd,
          win32.WINDOW_LONG_PTR_INDEX.GWLP_HWNDPARENT,
        );
        final exStyle = win32.GetWindowLongPtr(
          parentHwnd,
          win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
        );
        win32.SetWindowLongPtr(
          parentHwnd,
          win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
          exStyle &
              ~win32.WINDOW_EX_STYLE.WS_EX_LAYERED &
              ~win32.WINDOW_EX_STYLE.WS_EX_TRANSPARENT,
        );
        win32.DestroyWindow(hWnd);
      }
      break;
    case win32.WM_DESTROY:
      win32.PostQuitMessage(0);
      break;
    default:
      return win32.DefWindowProc(hWnd, uMsg, wParam, lParam);
  }
  return 0;
}

void showUnlockOverlay(int parentHwnd) {
  // Register the window class.
  final className = win32.TEXT('desktop_lyric_unlock_overlay');

  final lpfnWndProc = NativeCallable<win32.WNDPROC>.isolateLocal(
    mainWindowProc,
    exceptionalReturn: 0,
  );

  final hInstance = win32.GetModuleHandle(nullptr);

  final wc = ffi.calloc<win32.WNDCLASS>()
    ..ref.lpfnWndProc = lpfnWndProc.nativeFunction
    ..ref.hInstance = hInstance
    ..ref.lpszClassName = className;
  win32.RegisterClass(wc);

  // Create the window.
  final windowCaption = win32.TEXT('desktop_lyric_unlock_overlay');
  final hWnd = win32.CreateWindowEx(
    win32.WINDOW_EX_STYLE.WS_EX_TOPMOST |
        win32.WINDOW_EX_STYLE.WS_EX_LAYERED |
        win32.WINDOW_EX_STYLE.WS_EX_TOOLWINDOW,
    className, // Window class
    windowCaption, // Window caption
    win32.WINDOW_STYLE.WS_POPUP, // Window style

    // Size and position
    0,
    0,
    100,
    50,
    parentHwnd, // Parent window
    win32.NULL, // Menu
    hInstance, // Instance handle
    nullptr, // Additional application data
  );
  win32.free(windowCaption);
  win32.free(className);

  if (hWnd == 0) {
    final error = win32.GetLastError();
    throw win32.WindowsException(win32.HRESULT_FROM_WIN32(error));
  }

  // 设置窗口透明度为70%
  win32.SetLayeredWindowAttributes(
    hWnd,
    0,
    (255 * 70) ~/ 100,
    win32.LAYERED_WINDOW_ATTRIBUTES_FLAGS.LWA_ALPHA,
  );

  win32.ShowWindow(hWnd, win32.SHOW_WINDOW_CMD.SW_SHOW);

  // 定位到指定窗口左上角
  final targetRect = ffi.calloc<win32.RECT>();
  win32.GetWindowRect(parentHwnd, targetRect);
  win32.SetWindowPos(
    hWnd,
    win32.HWND_TOPMOST,
    targetRect.ref.left,
    targetRect.ref.top,
    100,
    50,
    win32.SET_WINDOW_POS_FLAGS.SWP_SHOWWINDOW,
  );
  ffi.calloc.free(targetRect);

  // Run the message loop.
  final msg = ffi.calloc<win32.MSG>();
  while (win32.GetMessage(msg, win32.NULL, 0, 0) != 0) {
    win32.TranslateMessage(msg);
    win32.DispatchMessage(msg);
  }

  lpfnWndProc.close();
  win32.free(msg);
}
