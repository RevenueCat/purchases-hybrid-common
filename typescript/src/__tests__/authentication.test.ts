import { IDENTITY_SOURCE } from "../authentication";

describe("IDENTITY_SOURCE", () => {
  // These must match the native IdentitySource raw values, which the bridges look sources up by.
  it("uses the native identity source raw values", () => {
    expect(IDENTITY_SOURCE.SIGN_IN_WITH_APPLE).toBe("apple");
    expect(IDENTITY_SOURCE.OIDC).toBe("oidc");
    expect(IDENTITY_SOURCE.GOOGLE).toBe("google");
    expect(IDENTITY_SOURCE.FIREBASE).toBe("firebase");
    expect(IDENTITY_SOURCE.FACEBOOK).toBe("facebook");
  });

  it("does not expose the anonymous source", () => {
    expect(Object.values(IDENTITY_SOURCE)).not.toContain("anonymous");
  });
});
