// Juice All Rights Reserved

#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "FrontendUISubsystem.generated.h"

UCLASS()
class FRONTENDUI_API UFrontendUISubsystem : public UGameInstanceSubsystem
{
	GENERATED_BODY()
public:
	static UFrontendUISubsystem* Get(const UObject* WorldContextObject);

	//~ Begin USubsyem Interface
	virtual bool ShouldCreateSubsystem(UObject* Outer) const override;
	//~ End USubsyem Interface

	UFUNCTION(BlueprintCallable)
	void
	RegisterCreatedPrimaryLayoutWidget(UWidget_PrimaryLayout* InCreatedWidget);

private:
	UPROPERTY(Transient)
	UWidget_PrimaryLayout* CreatedPrimaryLayout;
};
