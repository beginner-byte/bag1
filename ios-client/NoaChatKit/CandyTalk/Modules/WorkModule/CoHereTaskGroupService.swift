import Foundation
import UIKit

/// CandyTalk member data accepted by the Worker task-group bridge.
struct CoHereTaskGroupMember {
    /// Stable CandyTalk user identifier used by group APIs.
    let userUID: String

    /// Current display name sent with the group-member request.
    let nickname: String
}

/// Reuses CandyTalk SDK group operations without coupling Worker to a native page controller.
final class CoHereTaskGroupService {
    /// Shared stateless service used by ordinary group creation and Worker task orchestration.
    static let shared = CoHereTaskGroupService()

    /// Creates one group owned by the current CandyTalk user and persists the returned group locally.
    ///
    /// - Parameters:
    ///   - title: Task title used as the group name; the server still owns final name validation.
    ///   - members: Unique friend identities excluding the current creator.
    ///   - completion: Main-thread result containing the persisted network group or a bounded SDK error.
    func createGroup(
        title: String,
        members: [CoHereTaskGroupMember],
        completion: @escaping (Result<LingIMGroup, Error>) -> Void
    ) {
        guard let user = NoaUserManager.sharedInstance().userInfo else {
            completion(.failure(error(code: "missing_user", message: "CandyTalk user is unavailable")))
            return
        }
        let normalizedMembers = uniqueMembers(members, excluding: user.userUID)
        guard normalizedMembers.count + 1 >= 3 else {
            completion(.failure(error(code: "insufficient_members", message: "At least three group members are required")))
            return
        }
        let normalizedTitle = String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(30))
        let parameters = NSMutableDictionary(dictionary: [
            "ownerUid": user.userUID ?? "",
            "ownerNickname": user.nickname ?? "",
            "userUid": user.userUID ?? "",
            "groupName": normalizedTitle,
            "groupMemberParams": normalizedMembers.map {
                ["userUid": $0.userUID, "nickName": $0.nickname]
            }
        ])
        NoaIMSDKManager.sharedTool().createGroup(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self,
                      let group = LingIMGroup.mj_object(withKeyValues: data) else {
                    completion(.failure(self?.error(code: "invalid_group", message: "CandyTalk returned an invalid group") ?? NSError()))
                    return
                }
                self.persist(group: group, preferredTitle: normalizedTitle)
                self.applyTitle(normalizedTitle, to: group) {
                    DispatchQueue.main.async { completion(.success(group)) }
                }
            },
            onFailure: { [weak self] code, message, _ in
                let sdkError = self?.error(code: String(code), message: message ?? "Group creation failed") ?? NSError()
                DispatchQueue.main.async { completion(.failure(sdkError)) }
            }
        )
    }

    /// Invites one CandyTalk friend into an existing team-owned group.
    ///
    /// - Parameters:
    ///   - groupID: Stable group identifier already bound by Worker.
    ///   - member: Newly joined Worker team member and CandyTalk identity.
    ///   - completion: Main-thread SDK acceptance or a bounded failure.
    func inviteMember(
        groupID: String,
        member: CoHereTaskGroupMember,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUserUID = NoaUserManager.sharedInstance().userInfo?.userUID,
              !groupID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !member.userUID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              member.userUID != currentUserUID else {
            completion(.failure(error(code: "invalid_member_invite", message: "CandyTalk member invitation is invalid")))
            return
        }
        let parameters = NSMutableDictionary(dictionary: [
            "groupId": groupID,
            "userUid": currentUserUID,
            "inviteDesc": "",
            "groupMemberParams": [["userUid": member.userUID, "nickName": member.nickname]]
        ])
        NoaIMSDKManager.sharedTool().groupInviteFriend(
            with: parameters,
            onSuccess: { _, _ in DispatchQueue.main.async { completion(.success(())) } },
            onFailure: { [weak self] code, message, _ in
                let inviteError = self?.error(code: String(code), message: message ?? "Group member invitation failed") ?? NSError()
                DispatchQueue.main.async { completion(.failure(inviteError)) }
            }
        )
    }

    /// Dissolves one group as the current owner; repeated missing-group responses remain SDK-defined.
    func dissolveGroup(
        groupID: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let userUID = NoaUserManager.sharedInstance().userInfo?.userUID,
              !groupID.isEmpty else {
            completion(.failure(error(code: "invalid_group", message: "CandyTalk group is unavailable")))
            return
        }
        let parameters = NSMutableDictionary(dictionary: ["groupId": groupID, "userUid": userUID])
        NoaIMSDKManager.sharedTool().groupDissolutionGroup(
            with: parameters,
            onSuccess: { _, _ in DispatchQueue.main.async { completion(.success(())) } },
            onFailure: { [weak self] code, message, _ in
                let sdkError = self?.error(code: String(code), message: message ?? "Group dissolution failed") ?? NSError()
                DispatchQueue.main.async { completion(.failure(sdkError)) }
            }
        )
    }

    /// Builds the native group chat controller from CandyTalk's local group cache.
    func chatViewController(groupID: String) -> UIViewController? {
        guard !groupID.isEmpty else {
            return nil
        }
        // Objective-C headers expose both values as implicitly non-null to Swift.
        let localGroup = NoaIMSDKManager.sharedTool().toolCheckMyGroup(with: groupID)
        let group = NoaMessageTools.dbGroupModel(toNetWork: localGroup)
        let controller = NoaChatViewController()
        controller.groupInfo = group
        controller.chatType = .groupChat
        controller.chatName = group.groupName
        controller.sessionID = group.groupId
        return controller
    }

    /// Inserts or refreshes one group in the same local database used by the session list.
    private func persist(group: LingIMGroup, preferredTitle: String) {
        if !preferredTitle.isEmpty {
            group.groupName = preferredTitle
        }
        group.isMessageInform = 1
        group.userGroupRole = 2
        group.isActiveEnabled = 1
        let localGroup = NoaMessageTools.netWorkGroupModel(toDBGroupModel: group)
        NoaIMSDKManager.sharedTool().toolInsertOrUpdateGroupModel(with: localGroup)
    }

    /// Applies the task title after creation; failure is non-fatal because the created group must still be bound.
    private func applyTitle(_ title: String, to group: LingIMGroup, completion: @escaping () -> Void) {
        guard !title.isEmpty,
              let userUID = NoaUserManager.sharedInstance().userInfo?.userUID else {
            completion()
            return
        }
        let parameters = NSMutableDictionary(dictionary: [
            "groupId": group.groupId ?? "",
            "groupName": title,
            "userUid": userUID
        ])
        NoaIMSDKManager.sharedTool().changeGroupName(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                self?.persist(group: group, preferredTitle: title)
                completion()
            },
            onFailure: { _, _, _ in completion() }
        )
    }

    /// Removes duplicate or empty member identifiers before they cross the SDK boundary.
    private func uniqueMembers(
        _ members: [CoHereTaskGroupMember],
        excluding ownerUID: String?
    ) -> [CoHereTaskGroupMember] {
        var seen = Set<String>()
        return members.filter { member in
            let identifier = member.userUID.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !identifier.isEmpty, identifier != ownerUID, !seen.contains(identifier) else {
                return false
            }
            seen.insert(identifier)
            return true
        }
    }

    /// Converts SDK failures into a stable NSError suitable for FlutterMethodChannel.
    private func error(code: String, message: String) -> NSError {
        NSError(domain: "CoHereTaskGroup", code: Int(code) ?? -1, userInfo: [
            NSLocalizedDescriptionKey: message,
            "code": code
        ])
    }
}
