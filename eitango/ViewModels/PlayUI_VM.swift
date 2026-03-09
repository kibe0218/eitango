// ================================================
//  💫【UIUpdate_PVM / 画面状態更新ロジック】
// ================================================
// 
//  【役割】
//  ・🖥 UI 表示に必要な状態を一括で再計算
//  ・🔁 カード・リスト・色・設定変更後の画面更新
//  ・🚦 フリップ処理や待機処理のリセット制御
// 
//  【基本フロー】
//  ① cancelFlag を立てて進行中処理を一旦停止
//  ② 各種状態（index / finish / flip）を初期化
//  ③ ColorSetting() で配色を再適用
//  ④ CoreData から最新データを読み込み
//  ⑤ cards / Enlist / Jplist を再構築
//  ⑥ UI が @Published の変更を検知して再描画
// 
//  【設計方針】
//  ・UI はこのファイルの関数を「きっかけ」として呼ぶだけ
//  ・View 側で状態を組み立てない
//  ・更新ロジックは updateView() に集約する
// 
//  【重要ルール】
//  ・⚠️ updateView() は状態を壊して作り直す前提
//  ・⚠️ shuffle / noshuffle の分岐はここでのみ行う
//  ・⚠️ index 操作は常に配列範囲チェックを行う
// 
//  【補足】
//  ・updateView は「画面を最初から描き直すスイッチ」
//  ・状態不整合が起きたらまずここを疑う
// 
// ================================================

import SwiftUI
import CoreData

class PlayUIUpdateViewModel {
    
    private let listSession: ListSession
    private let uiState: PlayUIState
    private let listRepository: ListRepositoryProtocol
    init(
        uiState: PlayUIState,
        listRepository: ListRepositoryProtocol,
        listSession: ListSession,
    ) {
        self.uiState = uiState
        self.listRepository = listRepository
        self.listSession = listSession
    }
    
    // 使うときにtaskstop
    func updateView() async throws {
        uiState.reset()
        guard listSession.lists.contains(where: {
            $0.id == uiState.play.selectedListId
        }) else {
            uiState.play.selectedListId = listSession.lists.first?.id
            print("🟡 selectedListId無効だったので初期化:")
        }
        saveSettings()
    }
}
