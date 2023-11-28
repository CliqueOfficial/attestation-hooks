// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.8.22;

import {Attestation as VeraxAttestation} from "lar/AttestationRegistry.sol";

struct EASAttestation {
    bytes32 uid; // A unique identifier of the attestation.
    bytes32 schema; // The unique identifier of the schema.
    uint64 time; // The time when the attestation was created (Unix timestamp).
    uint64 expirationTime; // The time when the attestation expires (Unix timestamp).
    uint64 revocationTime; // The time when the attestation was revoked (Unix timestamp).
    bytes32 refUID; // The UID of the related attestation.
    address recipient; // The recipient of the attestation.
    address attester; // The attester/sender of the attestation.
    bool revocable; // Whether the attestation is revocable.
    bytes data; // Custom attestation data.
}

/**
 * @title IConnector
 * @notice Interface for the Connector contract.
 */
interface IConnector {
    error InvalidProtocolId();

    /**
     * @notice Gets the attestation value by its ID.
     * @param protocolId The protocol ID (EAS or VERAX).
     * @param attestationId The attestation ID.
     * @return value The attestation value.
     */
    function getAttestationValueById(
        bytes32 protocolId,
        bytes32 attestationId
    ) external view returns (bytes memory value);

    /**
     * @notice Gets multiple attestation values by their IDs.
     * @param protocolId The protocol ID (EAS or VERAX).
     * @param attestationIds An array of attestation IDs.
     * @return values An array of attestation values.
     */
    function getAttestationValuesByIds(
        bytes32 protocolId,
        bytes32[] memory attestationIds
    ) external view returns (bytes[] memory values);

    // ================ EAS ================

    /**
     * @notice Gets the EAS attestation by its ID.
     * @param attestationId The attestation ID.
     * @return The EAS attestation.
     */
    function getEASAttestation(
        bytes32 attestationId
    ) external view returns (EASAttestation memory);

    /**
     * @notice Gets the received attestation UIDs.
     * @param recipient The recipient address.
     * @param schemaUID The schema UID.
     * @param start The start index.
     * @param length The length.
     * @param reverseOrder The order of the results.
     * @return An array of attestation UIDs.
     */
    function getReceivedAttestationUIDs(
        address recipient,
        bytes32 schemaUID,
        uint256 start,
        uint256 length,
        bool reverseOrder
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the received attestation UID count.
     * @param recipient The recipient address.
     * @param schemaUID The schema UID.
     * @return The count of attestation UIDs.
     */
    function getReceivedAttestationUIDCount(
        address recipient,
        bytes32 schemaUID
    ) external view returns (uint256);

    /**
     * @notice Gets the sent attestation UIDs.
     * @param attester The attester address.
     * @param schemaUID The schema UID.
     * @param start The start index.
     * @param length The length.
     * @param reverseOrder The order of the results.
     * @return An array of attestation UIDs.
     */
    function getSentAttestationUIDs(
        address attester,
        bytes32 schemaUID,
        uint256 start,
        uint256 length,
        bool reverseOrder
    ) external view returns (bytes32[] memory);

    function getSentAttestationUIDCount(
        address attester,
        bytes32 schemaUID
    ) external view returns (uint256);

    /**
     * @notice Gets the schema attester recipient attestation UIDs.
     * @param schemaUID The schema UID.
     * @param attester The attester address.
     * @param recipient The recipient address.
     * @param start The start index.
     * @param length The length.
     * @param reverseOrder The order of the results.
     * @return An array of attestation UIDs.
     */
    function getSchemaAttesterRecipientAttestationUIDs(
        bytes32 schemaUID,
        address attester,
        address recipient,
        uint256 start,
        uint256 length,
        bool reverseOrder
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the schema attester recipient attestation UID count.
     * @param schemaUID The schema UID.
     * @param attester The attester address.
     * @param recipient The recipient address.
     * @return The count of attestation UIDs.
     */
    function getSchemaAttesterRecipientAttestationUIDCount(
        bytes32 schemaUID,
        address attester,
        address recipient
    ) external view returns (uint256);

    /**
     * @notice Gets the schema attestation UIDs.
     * @param schemaUID The schema UID.
     * @param start The start index.
     * @param length The length.
     * @param reverseOrder The order of the results.
     * @return An array of attestation UIDs.
     */
    function getSchemaAttestationUIDs(
        bytes32 schemaUID,
        uint256 start,
        uint256 length,
        bool reverseOrder
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the schema attestation UID count.
     * @param schemaUID The schema UID.
     * @return The count of attestation UIDs.
     */
    function getSchemaAttestationUIDCount(
        bytes32 schemaUID
    ) external view returns (uint256);

    // ================ VERAX ================

    /**
     * @notice Gets the Verax attestation by its ID.
     * @param attestationId The attestation ID.
     * @return The Verax attestation.
     */
    function getVeraxAttestation(
        bytes32 attestationId
    ) external view returns (VeraxAttestation memory);

    /**
     * @notice Gets the attestation IDs by subject.
     * @param subject The subject.
     * @return An array of attestation IDs.
     */
    function getAttestationIdsBySubject(
        bytes calldata subject
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the attestation IDs by subject and by schema.
     * @param subject The subject.
     * @param schemaId The schema ID.
     * @return An array of attestation IDs.
     */
    function getAttestationIdsBySubjectBySchema(
        bytes calldata subject,
        bytes32 schemaId
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the attestation IDs by attester.
     * @param attester The attester address.
     * @return An array of attestation IDs.
     */
    function getAttestationIdsByAttester(
        address attester
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the attestation IDs by schema.
     * @param schema The schema.
     * @return An array of attestation IDs.
     */
    function getAttestationIdsBySchema(
        bytes32 schema
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the attestation IDs by portal.
     * @param portal The portal address.
     * @return An array of attestation IDs.
     */
    function getAttestationIdsByPortal(
        address portal
    ) external view returns (bytes32[] memory);

    /**
     * @notice Gets the attestation IDs by portal and by subject.
     * @param portal The portal address.
     * @param subject The subject.
     * @return An array of attestation IDs.
     */
    function getAttestationIdsByPortalBySubject(
        address portal,
        bytes calldata subject
    ) external view returns (bytes32[] memory);

    /**
     * @notice Sets the EAS protocol addresses.
     * @param _eas The address of the EAS contract.
     * @param _easIndexer The address of the EAS indexer contract.
     */
    function setEAS(address _eas, address _easIndexer) external;

    /**
     * @notice Sets the Verax protocol addresses.
     * @param _verax The address of the Verax contract.
     * @param _veraxIndexer The address of the Verax indexer contract.
     */
    function setVerax(address _verax, address _veraxIndexer) external;
}
