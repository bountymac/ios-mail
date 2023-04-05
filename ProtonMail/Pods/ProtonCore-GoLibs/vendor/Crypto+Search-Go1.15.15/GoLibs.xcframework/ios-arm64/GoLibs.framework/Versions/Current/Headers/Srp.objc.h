// Objective-C API for talking to github.com/ProtonMail/go-srp Go package.
//   gobind -lang=objc github.com/ProtonMail/go-srp
//
// File is generated by gobind. Do not edit.

#ifndef __Srp_H__
#define __Srp_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class SrpAuth;
@class SrpProofs;
@class SrpServer;

/**
 * Auth stores byte data for the calculation of SRP proofs.
 * Changed SrpAuto to Auth because the name will be used as srp.SrpAuto by other packages and as SrpSrpAuth on mobile
 * Also the data from the API called Auth. it could be match the meaning and reduce the confusion
 */
@interface SrpAuth : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewAuth Creates new Auth from strings input. Salt and server ephemeral are in
base64 format. Modulus is base64 with signature attached. The signature is
verified against server key. The version controls password hash algorithm.

Parameters:
	 - version int: The *x* component of the vector.
	 - username string: The *y* component of the vector.
	 - password []byte: The *z* component of the vector.
	 - b64salt string: The std-base64 formatted salt
Returns:
  - auth *Auth: the pre calculated auth information
  - err error: throw error
Usage:

Warnings:
	 - Be careful! Poos can hurt.
 */
- (nullable instancetype)init:(long)version username:(NSString* _Nullable)username password:(NSData* _Nullable)password b64salt:(NSString* _Nullable)b64salt signedModulus:(NSString* _Nullable)signedModulus serverEphemeral:(NSString* _Nullable)serverEphemeral;
/**
 * NewAuthForVerifier Creates new Auth from strings input. Salt and server ephemeral are in
base64 format. Modulus is base64 with signature attached. The signature is
verified against server key. The version controls password hash algorithm.

Parameters:
	 - version int: The *x* component of the vector.
	 - username string: The *y* component of the vector.
	 - password []byte: The *z* component of the vector.
	 - salt string:
Returns:
  - auth *Auth: the pre calculated auth information
  - err error: throw error
Usage:

Warnings:
	 - none.
 */
- (nullable instancetype)initForVerifier:(NSData* _Nullable)password signedModulus:(NSString* _Nullable)signedModulus rawSalt:(NSData* _Nullable)rawSalt;
@property (nonatomic) NSData* _Nullable modulus;
@property (nonatomic) NSData* _Nullable serverEphemeral;
@property (nonatomic) NSData* _Nullable hashedPassword;
@property (nonatomic) long version;
/**
 * GenerateProofs calculates SPR proofs.
 */
- (SrpProofs* _Nullable)generateProofs:(long)bitLength error:(NSError* _Nullable* _Nullable)error;
/**
 * GenerateVerifier verifier for update pwds and create accounts
 */
- (NSData* _Nullable)generateVerifier:(long)bitLength error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Proofs Srp Proofs object. Changed SrpProofs to Proofs because the name will be used as srp.SrpProofs by other packages and as SrpSrpProofs on mobile
ClientProof []byte  client proof
ClientEphemeral []byte  calculated from
ExpectedServerProof []byte
 */
@interface SrpProofs : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSData* _Nullable clientProof;
@property (nonatomic) NSData* _Nullable clientEphemeral;
@property (nonatomic) NSData* _Nullable expectedServerProof;
@end

/**
 * Server stores the internal state for the validation of SRP proofs.
 */
@interface SrpServer : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewServer creates a new server instance from the raw binary data.
 */
- (nullable instancetype)init:(NSData* _Nullable)modulusBytes verifier:(NSData* _Nullable)verifier bitLength:(long)bitLength;
/**
 * NewServerFromSigned creates a new server instance from the signed modulus and the binary verifier.
 */
- (nullable instancetype)initFromSigned:(NSString* _Nullable)signedModulus verifier:(NSData* _Nullable)verifier bitLength:(long)bitLength;
/**
 * NewServerWithSecret creates a new server instance without generating a random secret from the raw binary data.
Use with caution as the secret should not be reused.
 */
- (nullable instancetype)initWithSecret:(NSData* _Nullable)modulusBytes verifier:(NSData* _Nullable)verifier secretBytes:(NSData* _Nullable)secretBytes bitLength:(long)bitLength;
/**
 * GenerateChallenge is the first step for SRP exchange, and generates a valid challenge for the provided verifier.
 */
- (NSData* _Nullable)generateChallenge:(NSError* _Nullable* _Nullable)error;
/**
 * GetSharedSession returns the shared secret as byte if the session has concluded in valid state.
 */
- (NSData* _Nullable)getSharedSession:(NSError* _Nullable* _Nullable)error;
/**
 * IsCompleted returns true if the exchange has been concluded in valid state.
 */
- (BOOL)isCompleted;
/**
 * VerifyProofs Verifies the client proof and - if valid - generates the shared secret and returnd the server proof.
It concludes the exchange in valid state if successful.
 */
- (NSData* _Nullable)verifyProofs:(NSData* _Nullable)clientEphemeralBytes clientProofBytes:(NSData* _Nullable)clientProofBytes error:(NSError* _Nullable* _Nullable)error;
@end

FOUNDATION_EXPORT NSString* _Nonnull const SrpVersion;

@interface Srp : NSObject
/**
 * Implementation following the "context" package
 */
+ (NSError* _Nullable) deadlineExceeded;
+ (void) setDeadlineExceeded:(NSError* _Nullable)v;

/**
 * ErrDataAfterModulus found extra data after decode the modulus
 */
+ (NSError* _Nullable) errDataAfterModulus;
+ (void) setErrDataAfterModulus:(NSError* _Nullable)v;

/**
 * ErrInvalidSignature invalid modulus signature
 */
+ (NSError* _Nullable) errInvalidSignature;
+ (void) setErrInvalidSignature:(NSError* _Nullable)v;

// skipped variable RandReader with unsupported type: io.Reader

@end

/**
 * Argon2PreimageChallenge computes the base64 solution for a given Argon2 base64
challenge within deadlineUnixMilli milliseconds, if any was found. Deadlines are measured
on the wall clock, not the monotonic clock, due to unreliability on mobile devices.
deadlineUnixMilli = -1 means unlimited time.
 */
FOUNDATION_EXPORT NSString* _Nonnull SrpArgon2PreimageChallenge(NSString* _Nullable b64Challenge, int64_t deadlineUnixMilli, NSError* _Nullable* _Nullable error);

/**
 * ECDLPChallenge computes the base64 solution for a given ECDLP base64 challenge
within deadlineUnixMilli milliseconds, if any was found. Deadlines are measured on the
wall clock, not the monotonic clock, due to unreliability on mobile devices.
deadlineUnixMilli = -1 means unlimited time.
 */
FOUNDATION_EXPORT NSString* _Nonnull SrpECDLPChallenge(NSString* _Nullable b64Challenge, int64_t deadlineUnixMilli, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT NSString* _Nonnull SrpGetModulusKey(void);

/**
 * HashPassword returns the hash of password argument. Based on version number
following arguments are used in addition to password:
* 0, 1, 2: userName and modulus
* 3, 4: salt and modulus
 */
FOUNDATION_EXPORT NSData* _Nullable SrpHashPassword(long authVersion, NSData* _Nullable password, NSString* _Nullable userName, NSData* _Nullable salt, NSData* _Nullable modulus, NSError* _Nullable* _Nullable error);

/**
 * MailboxPassword get mailbox password hash

Parameters:
	 - password []byte: a mailbox password
	 - salt []byte: a salt is random 128 bits data
Returns:
  - hashed []byte: a hashed password
  - err error: throw error
 */
FOUNDATION_EXPORT NSData* _Nullable SrpMailboxPassword(NSData* _Nullable password, NSData* _Nullable salt, NSError* _Nullable* _Nullable error);

/**
 * NewAuth Creates new Auth from strings input. Salt and server ephemeral are in
base64 format. Modulus is base64 with signature attached. The signature is
verified against server key. The version controls password hash algorithm.

Parameters:
	 - version int: The *x* component of the vector.
	 - username string: The *y* component of the vector.
	 - password []byte: The *z* component of the vector.
	 - b64salt string: The std-base64 formatted salt
Returns:
  - auth *Auth: the pre calculated auth information
  - err error: throw error
Usage:

Warnings:
	 - Be careful! Poos can hurt.
 */
FOUNDATION_EXPORT SrpAuth* _Nullable SrpNewAuth(long version, NSString* _Nullable username, NSData* _Nullable password, NSString* _Nullable b64salt, NSString* _Nullable signedModulus, NSString* _Nullable serverEphemeral, NSError* _Nullable* _Nullable error);

/**
 * NewAuthForVerifier Creates new Auth from strings input. Salt and server ephemeral are in
base64 format. Modulus is base64 with signature attached. The signature is
verified against server key. The version controls password hash algorithm.

Parameters:
	 - version int: The *x* component of the vector.
	 - username string: The *y* component of the vector.
	 - password []byte: The *z* component of the vector.
	 - salt string:
Returns:
  - auth *Auth: the pre calculated auth information
  - err error: throw error
Usage:

Warnings:
	 - none.
 */
FOUNDATION_EXPORT SrpAuth* _Nullable SrpNewAuthForVerifier(NSData* _Nullable password, NSString* _Nullable signedModulus, NSData* _Nullable rawSalt, NSError* _Nullable* _Nullable error);

/**
 * NewServer creates a new server instance from the raw binary data.
 */
FOUNDATION_EXPORT SrpServer* _Nullable SrpNewServer(NSData* _Nullable modulusBytes, NSData* _Nullable verifier, long bitLength, NSError* _Nullable* _Nullable error);

/**
 * NewServerFromSigned creates a new server instance from the signed modulus and the binary verifier.
 */
FOUNDATION_EXPORT SrpServer* _Nullable SrpNewServerFromSigned(NSString* _Nullable signedModulus, NSData* _Nullable verifier, long bitLength, NSError* _Nullable* _Nullable error);

/**
 * NewServerWithSecret creates a new server instance without generating a random secret from the raw binary data.
Use with caution as the secret should not be reused.
 */
FOUNDATION_EXPORT SrpServer* _Nullable SrpNewServerWithSecret(NSData* _Nullable modulusBytes, NSData* _Nullable verifier, NSData* _Nullable secretBytes, long bitLength, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT NSData* _Nullable SrpRandomBits(long bits, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT NSData* _Nullable SrpRandomBytes(long byes, NSError* _Nullable* _Nullable error);

/**
 * VersionNumber get current library version
 */
FOUNDATION_EXPORT NSString* _Nonnull SrpVersionNumber(void);

#endif
